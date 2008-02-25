require 'date'
module DateTimeTextFieldHelpers
  def date_text_field(object_name, method, options = {})
    ActionView::Helpers::InstanceTag.new(object_name, method, self, nil, options.delete(:object)).to_date_text_field_tag(options)
  end
  
  def time_text_field(object_name, method, options = {})
    ActionView::Helpers::InstanceTag.new(object_name, method, self, nil, options.delete(:object)).to_time_text_field_tag(options)
  end
  
  def datetime_text_field(object_name, method, options = {})
    ActionView::Helpers::InstanceTag.new(object_name, method, self, nil, options.delete(:object)).to_datetime_text_field_tag(options)
  end

  def text_field_for_date_part(part, datetime, options = {})
    val = datetime ? (datetime.kind_of?(Fixnum) ? datetime : datetime.send(part)) : ''
    if options[:use_hidden]
      hidden_html(options[:field_name] || part, val, options)
    else
      value = val.blank? ? '' : leading_zero_on_single_digits(val)
      datetime_text_field_html(part, value, options.merge(:class => "#{part}_field"))
    end
  end
  
  
  # Extracts field name with position as params key to find
  # value user submitted for this field if any
  def extract_field_param_value(options)
    field_name = options[:name].scan(/\[(.*?)\]/).first.first
    param_value = nil
    if @template_object.params[@object_name] 
      param_value = @template_object.params[@object_name][field_name]
    end
    param_value
  end  
  
  # Constructs html for field and inserts value from params if exists
  # otherwise it uses the column value from the object. This allows
  # better user feedback if they have put in bogus values, they will 
  # be able see the value after submitting and getting an error back.
  def datetime_text_field_html(type, value, options)
    name_and_id_from_options(options, type)
    value = extract_field_param_value(options) || value
    size = case type
      when :hour, :minute, :second : 2
      when :year : 4
      else 2
    end
    datetime_text_field_html = %(<input type="text" id="#{options[:id]}" name="#{options[:name]}" size="#{size}" value="#{value}" class="#{options[:class]}" />)
  end
end

ActionView::Base.send(:include, DateTimeTextFieldHelpers)

ActionView::Helpers::InstanceTag.class_eval do  
  include DateTimeTextFieldHelpers

  def to_date_text_field_tag(options = {})
    date_or_time_text_field(options.merge(:discard_hour => true))
  end

  def to_time_text_field_tag(options = {})
    date_or_time_text_field options.merge(:discard_year => true, :discard_month => true)
  end

  def to_datetime_text_field_tag(options = {})
    date_or_time_text_field options
  end
  
  private
  
  # Adapted from the Rails source date_or_time_select method to use text fields
  # instead of selects and adds a few extra options
  def date_or_time_text_field(options)
    defaults = { :discard_type => true, 
                 :date_separator => '-',
                 :time_separator => ':',
                 :date_time_separator => '&mdash;', 
                 :class => 'date_time_field' }
                 
    options  = defaults.merge(options)
    datetime = value(object)
    datetime ||= default_time_from_options(options[:default]) unless options[:blank]

    position = { :year => 1, :month => 2, :day => 3, :hour => 4, :minute => 5, :second => 6 }

    order = (options[:order] ||= [:year, :month, :day])

    # Discard explicit and implicit by not being included in the :order
    discard = {}
    discard[:year]   = true if options[:discard_year] or !order.include?(:year)
    discard[:month]  = true if options[:discard_month] or !order.include?(:month)
    discard[:day]    = true if options[:discard_day] or discard[:month] or !order.include?(:day)
    discard[:hour]   = true if options[:discard_hour]
    discard[:minute] = true if options[:discard_minute] or discard[:hour]
    discard[:second] = true unless options[:include_seconds] && !discard[:minute]

    # If the day is hidden and the month is visible, the day should be set to the 1st so all month choices are valid
    # (otherwise it could be 31 and february wouldn't be a valid date)
    if datetime && discard[:day] && !discard[:month]
      datetime = datetime.change(:day => 1)
    end

    # Maintain valid dates by including hidden fields for discarded elements
    [:day, :month, :year].each { |o| order.unshift(o) unless order.include?(o) }

    # Ensure proper ordering of :hour, :minute and :second
    [:hour, :minute, :second].each { |o| order.delete(o); order.push(o) }

    date_or_time_text_field = ''
    order.reverse.each do |param|
      # Send hidden fields for discarded elements once output has started
      # This ensures AR can reconstruct valid dates using ParseDate
      next if discard[param] && date_or_time_text_field.empty?

      date_or_time_text_field.insert(0, self.send(:text_field_for_date_part, param, datetime, options_with_prefix(position[param], options.merge(:use_hidden => discard[param]))))
      date_or_time_text_field.insert(0,
        case param
          when :year, :month, :day then (discard[param] || order.index(param) == 0)  ? '' : " #{options[:date_separator]} "
          when :hour then (discard[:year] && discard[:day] ? "" : " #{options[:date_time_separator]} ")
          when :minute then " #{options[:time_separator]} "
          when :second then options[:include_seconds] ? " #{options[:time_separator]} " : ""          
          else ''
        end)
    end

    content_tag(:span, date_or_time_text_field, :class => options[:class], :id => "#{@object_name}_#{@method_name}")
  end      
end

ActionView::Helpers::FormBuilder.class_eval do
  def date_text_field(method, options = {})
    @template.date_text_field(@object_name, method, options.merge(:object => @object))
  end

  def time_text_field(method, options = {})
    @template.time_text_field(@object_name, method, options.merge(:object => @object))
  end

  def datetime_text_field(method, options = {})
    @template.datetime_text_field(@object_name, method, options.merge(:object => @object))
  end
end

Time.class_eval do
  alias :second :sec
  alias :minute :min
end

DateTime.class_eval do
  alias :second :sec
  alias :minute :min
end