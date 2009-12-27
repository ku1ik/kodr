module Kodr
  class OpenProjectAction < Action
    description "Open..."
    name "project_open"
    icon "document-open"
    
    def call(env)
      url = KDE::FileDialog::get_existing_directory_url(KDE::Url.new(""), App.instance, KDE::i18n("Open Project"))
      unless url.is_empty
        ProjectViewer.get_instance.open_project(url)
      end
    end
  end
  
  class CloseProjectAction < Action
    description "Close"
    name "project_close"
    icon "window-close"
    enabled false
    
    def call(env)
      ProjectViewer.get_instance.close
    end
  end
  
  class ToggleProjectViewerAction < Action
    description "Show Project View"
    name "project_view_toggle"
    enabled false
    checkable true
    
    def call(env)
      Action["project_view_toggle"].is_checked ? ProjectViewer.get_instance.restore : ProjectViewer.get_instance.hide
    end
  end
end
