class API::TranslationsController < API::RestfulController

  class TranslationUnavailableError < Exception; end
  rescue_from(TranslationUnavailableError) { |e| respond_with_standard_error e, 400 }

  def show
    render json: translations_for(:en, params[:lang])
  end

  private

  def translations_for(*locales)
    locales.map(&:to_s).uniq.reduce({}) do |translations, locale|
      translations.deep_merge YAML.load_file("config/locales/client.#{locale}.yml")[locale]
    end
  end

  def inline
    raise TranslationUnavailableError.new unless TranslationService.available?

    instance = load_and_authorize params[:model]
    self.resource = TranslationService.new.translate(instance)
    respond_with_resource
  end

end
