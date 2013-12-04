require 'globalize'

class Object
  def metaclass
    class << self; self; end
  end
end

module EasyGlobalize3Accessors

  def globalize_accessors(options = {})
    options.reverse_merge!(locales: I18n.available_locales, attributes: translated_attribute_names)

    metaclass.instance_eval do
      mattr_accessor :easy_attributes_list, :easy_locales
    end

    send(:"easy_attributes_list=", [])
    send(:"easy_locales=", options[:locales])

    each_attribute_and_locale(options) do |attr_name, locale|
      #send(:attr_accessible, "#{attr_name}_#{locale}".to_sym)
      define_accessors(attr_name, locale)
    end
  end

  private

  def define_accessors(attr_name, locale)
    easy_attributes_list << "#{attr_name}_#{locale}".to_sym

    define_getter(attr_name, locale)
    define_setter(attr_name, locale)
  end


  def define_getter(attr_name, locale)
    define_method :"#{attr_name}_#{locale}" do
      read_attribute(attr_name, locale: locale)
    end
  end

  def define_setter(attr_name, locale)
    define_method :"#{attr_name}_#{locale}=" do |value|
      write_attribute(attr_name, value, locale: locale)
    end
  end

  def each_attribute_and_locale(options)
    options[:attributes].each do |attr_name|
      options[:locales].each do |locale|
        yield attr_name, locale
      end
    end
  end

end

ActiveRecord::Base.extend EasyGlobalize3Accessors
