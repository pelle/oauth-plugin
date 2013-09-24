require 'rails/generators/erb/controller/controller_generator'

module Slim
  module Generators
    class OauthConsumerGenerator < Erb::Generators::Base
      source_root File.expand_path('../oauth_consumer_templates', __FILE__)

      argument :name, :type => :string, :default => 'Oauth'

      def copy_view_files
        template 'index.html.slim',              File.join('app/views', class_path, 'oauth_consumers', 'index.html.slim')
        template 'show.html.slim',               File.join('app/views', class_path, 'oauth_consumers', 'show.html.slim')
      end

      protected
      def handler
        :slim
      end
    end
  end
end
