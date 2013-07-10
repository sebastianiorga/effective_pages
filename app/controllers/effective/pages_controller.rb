module Effective
  class PagesController < ApplicationController
    skip_authorization_check if defined?(CanCan)
    respond_to :html

    def show
      @page ||= Effective::Page.find(params[:id])
      EffectivePages.authorized?(self, :read, @page)

      (raise ActiveRecord::RecordNotFound if @page.draft?) unless params[:mercury_frame]

      template = EffectivePages.templates[@page.template]
      template_info = EffectivePages.templates_info[@page.template]
      raise EffectivePages::TemplateNotFound.new(@page.template) unless template.kind_of?(HashWithIndifferentAccess)

      # Assign all content areas
      (template[:regions] || {}).each { |region, _| content_for(region, @page.regions[region]) }

      render "#{EffectivePages.templates_path.chomp('/')}/#{@page.template}", :layout => ((template_info[:layout].to_s rescue nil) || 'application')
    end

    def edit
      @page ||= Effective::Page.find(params[:id])
      EffectivePages.authorized?(self, :update, @page)

      if params[:mercury_frame]
        show
      elsif @page.snippets.present?
        render(:file => 'effective/mercury/_load_snippets', :layout => 'effective_mercury')
      else
        render(:text => '', :layout => 'effective_mercury')
      end
    end

    def update
      @page ||= Effective::Page.find(params[:id])
      EffectivePages.authorized?(self, :update, @page)

      # Do the update.
      params[:content].each do |region, vals|
        @page.regions[region] = vals[:value]
        (vals[:snippets] || []).each { |snippet, vals| @page.snippets[snippet] = vals }
      end

      if @page.save
        render :text => '', :status => 200
      else
        render :text => '', :status => :unprocessable_entity
      end
    end

    def submit
      @page ||= Effective::Page.find(params[:id])
      EffectivePages.authorized?(self, :read, @page)

      show
    end

    private

    # https://gist.github.com/hiroshi/985457
    def content_for(region, content)
      (@_content_for ||= {})[region] = content
    end

    def view_context
      super.tap do |view|
        (@_content_for || {}).each { |name, content| view.content_for name.to_sym, content.try(:html_safe) }
      end
    end
  end
end
