class Artist::CreateService < Crepe::Service
  def call(params)
    form = build_form(params: params)
    if form.save
      success(form: form)
    else
      failure(form: form)
    end
  end
end
