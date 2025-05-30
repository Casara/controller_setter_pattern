# Provides helper methods for Rails controllers to reduce boilerplate code
# associated with setting instance variables based on request parameters,
# typically for +before_action+ callbacks.
module ControllerSetterPattern
  # This module is automatically included into +ActionController::Base+
  # when the gem is loaded, making the +set+ class method available
  # in all controllers.
  module ActionController
    extend ActiveSupport::Concern

    module ClassMethods
      # Creates +before_action+ callbacks to set instance variables in a controller.
      # It aims to simplify common patterns of finding records (e.g., an Article by +params[:id]+)
      # and assigning them to instance variables (e.g., +@article+).
      #
      # === Parameters
      #
      # * +names+ (+Symbol+ or +Array<Symbol>): One or more names of the instance
      #   variables to set (e.g., +:article+, +:comment+). The last argument can
      #   be an options hash.
      #
      # === Options
      #
      # The options hash can include:
      #
      # * +:model+ (<tt>Class</tt>): Specifies the model class to use for finding the record.
      #   If not provided, the class is inferred from the instance variable name
      #   (e.g., +:article+ implies +Article+).
      #   Example: <tt>set :ebook, model: Book</tt>
      #
      # * +:finder_params+ (<tt>Symbol</tt> or <tt>Array<Symbol></tt>): Specifies the parameter(s)
      #   from the +params+ hash to use for finding the record.
      #   - If empty or not provided, defaults to using +params[:id]+ or +params[:<name>_id]+.
      #   - If a single symbol (e.g., +:token+), finds by that param: <tt>Model.find_by_token(params[:token])</tt>.
      #   - If an array (e.g., +[:user_id, :slug]+), finds by all those params:
      #     <tt>Model.find_by_user_id_and_slug(params[:user_id], params[:slug])</tt>.
      #   Example: <tt>set :article, finder_params: :slug</tt>
      #   Example: <tt>set :comment, finder_params: [:post_id, :comment_token]</tt>
      #
      # * +:ancestor+ (<tt>Symbol</tt>): The name of a previously set ancestor instance variable.
      #   The current resource will be looked up as an association of this ancestor.
      #   Example: <tt>set :post; set :comment, ancestor: :post</tt> (finds <tt>@post.comments.find(...)</tt>)
      #
      # * +:scope+ (<tt>Symbol</tt> or <tt>Array<Symbol></tt>): One or more scopes to apply to the model
      #   or association before finding the record.
      #   Example: <tt>set :user, scope: :active, finder_params: :email</tt> (calls <tt>User.active.find_by_email(...)</tt>)
      #   Example: <tt>set :article, scope: [:published, :featured]</tt>
      #
      # * Standard +before_action+ options: Options like +:only+, +:except+, +:if+, +:unless+
      #   are passed directly to the underlying +before_action+ call.
      #   Example: <tt>set :article, only: [:show, :edit]</tt>
      #
      # === Examples
      #
      #   class ArticlesController < ApplicationController
      #     # Sets @article = Article.find(params[:id]) for show, edit, update, destroy
      #     set :article, except: [:index, :new, :create]
      #
      #     # Sets @user = User.active.find_by_token(params[:user_token]) for the activate action
      #     set :user, model: User, scope: :active, finder_params: :user_token, only: :activate
      #   end
      #
      #   class CommentsController < ApplicationController
      #     set :post # Sets @post = Post.find(params[:post_id])
      #     set :comment, ancestor: :post, except: [:index, :new, :create] # Sets @comment = @post.comments.find(params[:id])
      #   end
      #
      def set(*names)
        # Extract standard before_action options (e.g., :only, :except, :if, :unless)
        filter_options = names.last.is_a?(Hash) ? names.last.slice(:only, :except, :if, :unless) : {}

        # Extract custom options for this gem's setter logic
        custom_setter_opts_input = names.last.is_a?(Hash) ? names.last.except(*filter_options.keys) : {}

        # Determine the actual names for setters (excluding the options hash if present)
        setter_names = names.last.is_a?(Hash) ? names[0..-2] : names

        options = _prepare_setter_logic_options(custom_setter_opts_input)
        _insert_setters(setter_names, options, filter_options)
      end

      private

      # Prepares the internal options hash for the setter logic based on custom options
      # provided to the +set+ method.
      #
      # Parameters:
      #   custom_opts (Hash): The custom options extracted from the +set+ method call.
      #
      # Returns:
      #   Hash: A structured options hash for internal use.
      def _prepare_setter_logic_options(custom_opts)
        options = {}
        options[:model] = custom_opts[:model].to_s.camelize.constantize if custom_opts[:model]
        options[:finder_params] = _normalize_finder_params(custom_opts.fetch(:finder_params, []))
        options[:finder_method] =
          "find#{options[:finder_params].empty? ? '' : "_by_#{options[:finder_params].join('_and_')}"}"
        options[:ancestor] = custom_opts[:ancestor]
        options[:scope] = custom_opts[:scope]
        options
      end

      # Normalizes the +finder_params+ option. Ensures it's an array and removes duplicates.
      # Clears the array if it only contains 'id', as this is the default behavior.
      def _normalize_finder_params(finder_params)
        finder_params = [finder_params] unless finder_params.is_a?(Array)
        finder_params = finder_params.compact.uniq
        # Default find is by :id, so explicitly providing only :id is redundant for find_by_id
        finder_params.clear if finder_params.one? && finder_params.join.eql?('id')
        finder_params
      end

      # Iterates over the setter names and creates a +before_action+ for each one.
      def _insert_setters(setters, options, callback_options)
        setters.each do |setter|
          before_action callback_options do |controller|
            resource = _get_resource(setter, options[:model], options[:ancestor])
            if _is_class_model_or_association_method?(resource)
              resource = _get_resource_by_finder(resource, setter,
                                                 options)
            end
            controller.instance_variable_set(:"@#{setter}", resource)
          end
        end
      end
    end

    private

    # Retrieves a resource by applying scopes (if any) and then calling the
    # constructed finder method with the appropriate parameter values.
    #
    # Parameters:
    #   resource (Class or ActiveRecord::Relation): The base model/relation to find from.
    #   setter (Symbol): The name of the instance variable being set (used for default param key).
    #   options (Hash): The prepared setter logic options.
    def _get_resource_by_finder(resource, setter, options)
      # Apply scopes if any
      Array(options[:scope]).each { |s| resource = resource.public_send(s) } if options[:scope].present?

      values_for_find = _get_values_for_finder_params(setter, options[:finder_params])
      resource.public_send(options[:finder_method], *values_for_find)
    end

    # Determines the initial resource object or class.
    # This can be an ancestor's association, a specified model, or a class inferred
    # from the setter name.
    def _get_resource(setter, model, ancestor)
      if ancestor.present?
        _get_ancestor_resource(setter, model, ancestor)
      else
        # Use provided model or infer from setter name
        is_ar_model = model.respond_to?(:descends_from_active_record?) &&
                      model.descends_from_active_record?
        if is_ar_model
          model
        else
          setter.to_s.camelize.constantize
        end
      end
    end

    # Retrieves a resource through an association on an ancestor resource.
    # The ancestor resource itself is either already set as an instance variable
    # or found using its conventional parameter key (e.g., +params[:user_id]+ for an ancestor +:user+).
    def _get_ancestor_resource(setter, model, ancestor)
      ancestor_instance_var_name = "@#{ancestor}"
      ancestor_resource = if instance_variable_defined?(ancestor_instance_var_name)
                            instance_variable_get(ancestor_instance_var_name)
                          else
                            # Infer ancestor model and find by its conventional foreign key in params
                            ancestor_model_class = ancestor.to_s.camelize.constantize
                            # This find is generally safe as it's typically an ID.
                            # For robustness, ideally this param would be explicitly permitted by the controller.
                            param_key = :"#{ancestor_model_class.name.underscore}_id"
                            ancestor_model_class.find(params[param_key])
                          end

      reflection_method_name = _get_reflection_method(ancestor_resource.class, model || setter)
      return unless reflection_method_name && ancestor_resource.respond_to?(reflection_method_name)

      ancestor_resource.public_send(reflection_method_name)
    end

    # Determines the name of the association method to call on an ancestor resource.
    # It tries both singular and plural forms of the target resource name.
    def _get_reflection_method(klass, assoc_class)
      # Convert assoc_class (which could be a class or symbol) to string for consistent processing
      assoc_name_str = assoc_class.to_s.underscore
      singular_name = assoc_name_str.singularize.to_sym
      plural_name = assoc_name_str.pluralize.to_sym

      # Check for singular association first, then plural
      reflection = klass.reflect_on_association(singular_name) || klass.reflect_on_association(plural_name)

      reflection&.name # Return the actual name of the association (e.g., :user or :users)
    end

    # Checks if the given resource is a class (e.g., User) or an ActiveRecord
    # association proxy (e.g., user.posts), which means it's a scope to be further queried.
    def _is_class_model_or_association_method?(resource)
      resource.is_a?(Class) || resource.is_a?(ActiveRecord::Associations::CollectionProxy)
    end

    # Extracts the values from +params+ that correspond to the +finder_params+
    # defined in the +set+ method options.
    # Handles the default case (using +:id+ or +:<setter>_id+) and custom finder params.
    def _get_values_for_finder_params(setter, finder_params)
      if finder_params.empty?
        # Default case: find by :id or :<setter>_id.
        # These params should ideally be permitted by the controller if not standard route params.
        params[:"#{setter}_id"] || params[:id]
      else
        # Custom finder_params: ensure they are permitted and extract values in order.
        string_finder_params = finder_params.map(&:to_s)
        permitted_params = params.permit(*string_finder_params)

        string_finder_params.map { |key| permitted_params[key] }
      end
    end
  end
end
