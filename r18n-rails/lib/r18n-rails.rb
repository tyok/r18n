# frozen_string_literal: true

# R18n support for Rails.
#
# Copyright (C) 2009 Andrey “A.I.” Sitnik <andrey@sitnik.ru>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'r18n-core'
require 'r18n-rails-api'

require_relative 'r18n-rails/helpers'
require_relative 'r18n-rails/controller'
require_relative 'r18n-rails/translated'
require_relative 'r18n-rails/filters'

R18n.default_places { [Rails.root.join('app/i18n'), R18n::Loader::Rails.new] }

ActionController::Base.helper(R18n::Rails::Helpers)
ActionController::Base.send(:include, R18n::Rails::Controller)

if ActionController::Base.respond_to? :before_action
  ActionController::Base.send(:before_action, :set_r18n)
  if Rails.env.development?
    ActionController::Base.send(:before_action, :reload_r18n)
  end
else
  ActionController::Base.send(:before_filter, :set_r18n)
  if Rails.env.development?
    ActionController::Base.send(:before_filter, :reload_r18n)
  end
end

ActionMailer::Base.helper(R18n::Rails::Helpers) if defined? ActionMailer

ActiveSupport.on_load(:after_initialize) do
  env = ENV['LANG']
  env = env.split('.').first if env
  locale = env || I18n.default_locale.to_s
  if defined?(Rails::Console) && !defined?(Wirble)
    i18n = R18n::I18n.new(
      locale, R18n.default_places,
      off_filters: :untranslated,
      on_filters: :untranslated_bash
    )
    R18n.set(i18n)
  else
    R18n.set(locale)
  end

  I18n.backend = R18n::Backend.new
end
