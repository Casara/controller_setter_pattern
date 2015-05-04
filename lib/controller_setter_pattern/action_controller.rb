module ControllerSetterPattern
  module ActionController
    extend ActiveSupport::Concern

    module ClassMethods
      def set(*names)
        options = names.extract_options!

        model = options.delete(:model)
        model = model.to_s.camelize.constantize unless model.nil?

        finder_params = normalize_finder_params(options.delete(:finder_params) || [])
        finder_method = 'find' + (finder_params.empty? ? '' : '_by_' + finder_params.join('_and_'))

        ancestor = options.delete(:ancestor)
        scope = options.delete(:scope)

        names.each do |variable|
          before_action options do |controller|
            if !ancestor.nil?
              if controller.instance_variable_defined?("@#{ancestor}")
                resource = controller.instance_variable_get("@#{ancestor}")
                model_class = resource.class
              else
                model_class = ancestor.to_s.camelize.constantize
                resource = model_class.find(params["#{model_class.name.underscore}_id".to_sym])
              end
              reflection_name = (model || variable).to_s.underscore.pluralize.to_sym
              resource = resource.send(reflection_name) if resource.respond_to?(reflection_name)
            elsif !model.nil? && model.descends_from_active_record?
              model_class = model
            elsif
              model_class = variable.to_s.camelize.constantize
            end

            resource ||= model_class

            unless scope.nil?
              scope = [scope] unless scope.is_a?(Array)
              scope.each { |s| resource = resource.send(s) }
            end

            if finder_params.empty?
              values_for_find = controller.params["#{variable}_id".to_sym] || controller.params[:id]
            else
              defaults = finder_params.inject({}) { |h, v| h.merge(v.to_s => nil) }
              values_for_find = defaults.merge(controller.params.permit(finder_params)).values
            end

            resource = resource.send(finder_method, *values_for_find)

            var_name = "@#{variable}".to_sym
            controller.instance_variable_set(var_name, resource)
          end
        end
      end

      private
        def normalize_finder_params(finder_params)
          finder_params = [finder_params] unless finder_params.is_a?(Array)
          finder_params = finder_params.compact.uniq
          finder_params.clear if finder_params.one? && finder_params.join.eql?('id')
          finder_params
        end
    end
  end
end