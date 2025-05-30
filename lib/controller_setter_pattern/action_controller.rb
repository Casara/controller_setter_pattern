module ControllerSetterPattern
  module ActionController
    extend ActiveSupport::Concern

    module ClassMethods
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

      def _normalize_finder_params(finder_params)
        finder_params = [finder_params] unless finder_params.is_a?(Array)
        finder_params = finder_params.compact.uniq
        finder_params.clear if finder_params.one? && finder_params.join.eql?('id')
        finder_params
      end

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

    def _get_resource_by_finder(resource, setter, options)
      # Apply scopes if any
      Array(options[:scope]).each { |s| resource = resource.public_send(s) } if options[:scope].present?

      values_for_find = _get_values_for_finder_params(setter, options[:finder_params])
      resource.public_send(options[:finder_method], *values_for_find)
    end

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

    def _get_ancestor_resource(setter, model, ancestor)
      ancestor_instance_var_name = "@#{ancestor}"
      ancestor_resource = if instance_variable_defined?(ancestor_instance_var_name)
                            instance_variable_get(ancestor_instance_var_name)
                          else
                            # Infer ancestor model and find by its conventional foreign key in params
                            ancestor_model_class = ancestor.to_s.camelize.constantize
                            # Ensure param_key is permitted if used beyond simple find
                            param_key = :"#{ancestor_model_class.name.underscore}_id"
                            # This find is generally safe as it's typically an ID.
                            ancestor_model_class.find(params[param_key])
                          end

      reflection_method_name = _get_reflection_method(ancestor_resource.class, model || setter)
      return unless reflection_method_name && ancestor_resource.respond_to?(reflection_method_name)

      ancestor_resource.public_send(reflection_method_name)
    end

    def _get_reflection_method(klass, assoc_class)
      # Convert assoc_class (which could be a class or symbol) to string for consistent processing
      assoc_name_str = assoc_class.to_s.underscore
      singular_name = assoc_name_str.singularize.to_sym
      plural_name = assoc_name_str.pluralize.to_sym

      # Check for singular association first, then plural
      reflection = klass.reflect_on_association(singular_name) || klass.reflect_on_association(plural_name)

      reflection&.name # Return the actual name of the association (e.g., :user or :users)
      # instead of reflection.options[:as] which might be for polymorphism
    end

    def _is_class_model_or_association_method?(resource)
      resource.is_a?(Class) || resource.is_a?(ActiveRecord::Associations::CollectionProxy)
    end

    def _get_values_for_finder_params(setter, finder_params)
      if finder_params.empty?
        # For a simple find by ID, ensure :id is permitted if it's not the default :id from routing.
        # If params["#{setter}_id"] is used, it should be explicitly permitted.
        # For now, assuming standard :id or that "#{setter}_id" is a route parameter.
        # A more robust solution would involve controller explicitly permitting these.
        params[:"#{setter}_id"] || params[:id]
      else
        # Ensure finder_params are strings for permit, then map to fetch values in order.
        string_finder_params = finder_params.map(&:to_s)
        permitted_params = params.permit(*string_finder_params)

        # Extract values in the order of original finder_params
        string_finder_params.map { |key| permitted_params[key] }
      end
    end
  end
end
