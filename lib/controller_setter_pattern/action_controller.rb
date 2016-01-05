module ControllerSetterPattern
  module ActionController
    extend ActiveSupport::Concern

    module ClassMethods
      def set(*names)
        callback_options = names.extract_options!

        (options ||= {})[:model] = callback_options.delete(:model)
        options[:model] ||= options[:model].to_s.camelize.constantize unless options[:model].nil?

        options[:finder_params] = _normalize_finder_params(callback_options.delete(:finder_params) || [])
        options[:finder_method] = 'find' + (options[:finder_params].empty? ? '' : '_by_' + options[:finder_params].join('_and_'))

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
      Array(options[:scope]).each { |s| resource = resource.send(s) } unless options[:scope].nil?
      values_for_find = _get_values_for_finder_params(setter, options[:finder_params])
      resource.send(options[:finder_method], *values_for_find)
    end

    def _get_resource(setter, model, ancestor)
      if !ancestor.nil?
        _get_ancestor_resource(setter, model, ancestor)
      else
        (!model.nil? && model.descends_from_active_record?) ? model : setter.to_s.camelize.constantize
      end
    end

    def _get_ancestor_resource(setter, model, ancestor)
      if instance_variable_defined?("@#{ancestor}")
        resource = instance_variable_get("@#{ancestor}")
      else
        model_class = ancestor.to_s.camelize.constantize
        resource = model_class.find(params["#{model_class.name.underscore}_id".to_sym])
      end
      reflection_method = _get_reflection_method(resource.class, model || setter)
      resource.send(reflection_method) if resource.respond_to?(reflection_method)
    end

    def _get_reflection_method(klass, assoc_class)
      singular_name = assoc_class.to_s.underscore.singularize.to_sym
      plural_name = assoc_class.to_s.underscore.pluralize.to_sym
      reflection = klass.reflect_on_association(singular_name) || klass.reflect_on_association(plural_name)
      (reflection.options[:as] || reflection.name) unless reflection.nil?
    end

    def _is_class_model_or_association_method?(resource)
      resource.is_a?(Class) || resource.class.ancestors.include?(ActiveRecord::Associations::CollectionProxy)
    end

    def _get_values_for_finder_params(setter, finder_params)
      if finder_params.empty?
        values_for_find = params["#{setter}_id".to_sym] || params[:id]
      else
        defaults = finder_params.inject({}) { |h, v| h.merge(v.to_s => nil) }
        values_for_find = defaults.merge(params.permit(finder_params)).values
      end
    end
  end
end