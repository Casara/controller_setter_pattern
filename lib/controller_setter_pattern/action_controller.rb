module ControllerSetterPattern
  module ActionController
    extend ActiveSupport::Concern

    module ClassMethods
      def set(*names)
        callback_options = names.extract_options!
        options = {} # Initialize options hash

        model_option = callback_options.delete(:model)
        options[:model] = model_option.to_s.camelize.constantize if model_option

        options[:finder_params] = _normalize_finder_params(callback_options.delete(:finder_params) || [])
        options[:finder_method] = "find#{options[:finder_params].empty? ? '' : '_by_' + options[:finder_params].join('_and_')}"

        options[:ancestor] = callback_options.delete(:ancestor)
        options[:scope] = callback_options.delete(:scope)

        _insert_setters(names, options, callback_options)
      end

      private

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
            resource = _get_resource_by_finder(resource, setter, options) if _is_class_model_or_association_method?(resource)
            controller.instance_variable_set("@#{setter}".to_sym, resource)
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
        (model && model.respond_to?(:descends_from_active_record?) && model.descends_from_active_record?) ? model : setter.to_s.camelize.constantize
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
                            param_key = "#{ancestor_model_class.name.underscore}_id".to_sym
                            # This find is generally safe as it's typically an ID.
                            ancestor_model_class.find(params[param_key])
                          end

      reflection_method_name = _get_reflection_method(ancestor_resource.class, model || setter)
      ancestor_resource.public_send(reflection_method_name) if reflection_method_name && ancestor_resource.respond_to?(reflection_method_name)
    end

    def _get_reflection_method(klass, assoc_class)
      # Convert assoc_class (which could be a class or symbol) to string for consistent processing
      assoc_name_str = assoc_class.to_s.underscore
      singular_name = assoc_name_str.singularize.to_sym
      plural_name = assoc_name_str.pluralize.to_sym

      # Check for singular association first, then plural
      reflection = klass.reflect_on_association(singular_name) || klass.reflect_on_association(plural_name)

      reflection.name if reflection # Return the actual name of the association (e.g., :user or :users)
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
        params["#{setter}_id".to_sym] || params[:id]
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