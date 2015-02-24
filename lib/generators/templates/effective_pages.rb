# EffectivePages Rails Engine

EffectivePages.setup do |config|
  config.pages_table_name = :pages
  config.menus_table_name = :menus
  config.menu_items_table_name = :menu_items

  # The directory where your page templates live
  # Any files in this directory will be automatically available when
  # creating/editting an Effective::Page from the Admin screens
  # Relative to app/views/
  config.pages_path = '/effective/pages/'

  # Excluded Pages
  # Any page templates from the above directory that should be excluded
  config.excluded_pages = []

  # Excluded Layouts
  # Any app/views/layouts/ layout files that should be excluded
  config.excluded_layouts = [:admin]

  # Use CanCan: can?(action, resource)
  # Use effective_roles:  resource.roles_permit?(current_user)
  config.authorization_method = Proc.new { |controller, action, resource| true }

  # Layout Settings
  # Configure the Layout per controller, or all at once

  # The layout for the EffectivePages admin screen
  config.layout = {
    :admin => 'application'
  }

  # This string will be appended to the effective_pages_header_tags title tag
  config.site_title_suffix = " | #{Rails.application.class.name.split('::').first.titleize}"

  # SimpleForm Options
  # This Hash of options will be passed into any simple_form_for() calls
  config.simple_form_options = {}

  # config.simple_form_options = {
  #   :html => {:class => 'form-horizontal'},
  #   :wrapper => :horizontal_form,
  #   :wrapper_mappings => {
  #     :boolean => :horizontal_boolean,
  #     :check_boxes => :horizontal_radio_and_checkboxes,
  #     :radio_buttons => :horizontal_radio_and_checkboxes
  #   }
  # }

  # All effective_page menu options
  config.menu = {
    :apply_active_class => true,  # Add an .active class to the appropriate li item based on current page url
    :maxdepth => 2                # 2 by default, strict bootstrap3 doesnt support dropdowns in your dropdowns
  }

end
