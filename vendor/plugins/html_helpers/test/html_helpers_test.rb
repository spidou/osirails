module ActionView
  module Helpers
  end
end

require 'test/unit'
require 'init'

class HtmlHelpersTest < Test::Unit::TestCase
  include ActionView::Helpers::TextHelper

  def test_basic_encoding
    assert_equal encode_entities("This is <em>emphasized</em>!"), "This is &lt;em&gt;emphasized&lt;/em&gt;!"
  end

  def test_basic_decoding
    assert_equal decode_entities("This is &lt;em&gt;emphasized&lt;/em&gt;!"), "This is <em>emphasized</em>!"
  end
  
  def test_decoding_numeric_entities
    assert_equal decode_entities("This is &#60;em&#62;emphasized&#60;/em&#62;!"), "This is <em>emphasized</em>!"
  end

  def test_decoding_hex_entities
    assert_equal decode_entities("This is &#x3C;em&#x3E;emphasized&#x3C;/em&#x3E;!"), "This is <em>emphasized</em>!"
  end

  def test_decoding_mixed_entities
    assert_equal decode_entities("This is &lt;em&#x3E;emphasized&lt;/em&#62;!"), "This is <em>emphasized</em>!"
  end

  def test_text_encoding
    assert_equal encode_entities("Ursache sind die hohen Zuflüsse des Regen, der Teile des Bayerischen Waldes entwässert.\nDort ist immer noch die Schneeschmelze im Gange, außerdem hat es Freitag dort teils kräftige Schauer gegeben."), "Ursache sind die hohen Zufl&uuml;sse des Regen, der Teile des Bayerischen Waldes entw&auml;ssert.\nDort ist immer noch die Schneeschmelze im Gange, au&szlig;erdem hat es Freitag dort teils kr&auml;ftige Schauer gegeben."
  end

  def test_text_decoding
    assert_equal decode_entities("Ursache sind die hohen Zufl&uuml;sse des Regen, der Teile des Bayerischen Waldes entw&auml;ssert.\nDort ist immer noch die Schneeschmelze im Gange, au&szlig;erdem hat es Freitag dort teils kr&auml;ftige Schauer gegeben."), "Ursache sind die hohen Zuflüsse des Regen, der Teile des Bayerischen Waldes entwässert.\nDort ist immer noch die Schneeschmelze im Gange, außerdem hat es Freitag dort teils kräftige Schauer gegeben."
  end
end
