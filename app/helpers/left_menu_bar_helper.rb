module LeftMenuBarHelper

  def dashboard_are_selected?
    controller_name == 'dashboards'
  end

  def projects_are_selected?
    controller_name.in? %w(projects experiments my_modules)
  end

  def repositories_are_selected?
    controller_name == 'repositories'
  end

  def templates_are_selected?
    # TODO
    controller_name == 'protocols'
  end

  def reports_are_selected?
    # TODO
    controller_name == 'reports'
  end

  def settings_are_selected?
    controller_name.in? %(registrations preferences addons teams connected_accounts webhooks)
  end

  def activities_are_selected?
    controller_name == 'global_activities'
  end
end
