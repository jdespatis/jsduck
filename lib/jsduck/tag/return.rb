require "jsduck/tag/tag"
require "jsduck/doc/subproperties"

module JsDuck::Tag
  class Return < Tag
    def initialize
      @pattern = ["return", "returns"]
      @key = :return
    end

    # @return {Type} return.name ...
    def parse(p)
      tag = p.standard_tag({:tagname => :return, :type => true})
      tag[:name] = subproperty_name(p)
      tag[:doc] = :multiline
      tag
    end

    def subproperty_name(p)
      if p.hw.look(/return\.\w/)
        p.ident_chain
      else
        "return"
      end
    end

    def process_doc(h, tags, pos)
      ret = tags[0]
      h[:return] = {
        :type => ret[:type] || "Object",
        :name => ret[:name] || "return",
        :doc => ret[:doc] || "",
        :properties => nest_properties(tags, pos)[0][:properties]
      }
    end

    def nest_properties(tags, pos)
      items, warnings = JsDuck::Doc::Subproperties.nest(tags)
      warnings.each {|msg| JsDuck::Logger.warn(:subproperty, msg, pos[:filename], pos[:linenr]) }
      items
    end
  end
end