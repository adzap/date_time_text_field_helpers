module DateTimeTextFieldHelpers
  class Railtie < Rails::Railtie
    config.app_middleware.use DateTimeTextFieldHelpers::Middleware

    initializer 'date_time_text_field_helpers.mixin' do
      ActionView::Base.send(:include, DateTimeTextFieldHelpers::FormHelpers)
      ActionView::Helpers::InstanceTag.send(:include, DateTimeTextFieldHelpers::InstanceTag)
      ActionView::Helpers::FormBuilder.send(:include, DateTimeTextFieldHelpers::FormBuilder)
    end
  end
end
