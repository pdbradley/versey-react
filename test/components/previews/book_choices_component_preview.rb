class BookChoicesComponentPreview < ViewComponent::Preview

  layout 'component_preview'

  def whut
    render(BookChoicesComponent.new(verse: foo))
  end

  private

  def foo
    verse = FactoryBot.build_stubbed(:stubbed_verse)
    verse
  end

end
