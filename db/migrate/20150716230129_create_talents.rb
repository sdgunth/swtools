class CreateTalents < ActiveRecord::Migration
  def change
    create_table :talents do |t|
      
      # The symbols for various special symbols and their unicode dopplers
      # are as follows: 
      #    "[:b:]"  => ["boost", "b"],
      #    "[:a:]"  => ["ability", "d"],
      #    "[:p:]"  => ["proficiency", "c"],
      #    "[:s:]"  => ["setback", "b"],
      #    "[:d:]"  => ["difficulty", "d"],
      #    "[:c:]"  => ["challenge", "c"],
      #    "[:f:]"  => ["force", "c"],
      #    "[:fl:]" => ["force-light", "z"],
      #    "[:fd:]" => ["force-dark", "z"],
      #    "[:fa:]" => ["force-agnostic", "*"],
      #    "[:ad:]" => ["advantage", "a"],
      #    "[:su:]" => ["success", "s"],
      #    "[:tr:]" => ["triumph", "x"],
      #    "[:th:]" => ["threat", "t"],
      #    "[:fr:]" => ["failure", "f"],
      #    "[:ds:]" => ["despair", "y"]
      
      # The name of the talent
      t.string :name
      # The quick description of the talent - the one that goes on the tree
      t.text :quick_desc
      # The full description of the talent - like in the talents chapter
      t.text :full_desc
      # True if the talent is homebrew, false otherwise
      t.boolean :homebrew
      # Contains a page reference, in the format "#{gameline}: #{book}, pg. #{pagenum}"
      t.string :pageref
      # True if the talent is a Force talent, false otherwise
      t.boolean :force
      # True if the talent is active, false if it is passive
      t.boolean :active
    end
  end
end
