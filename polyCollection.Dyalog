:Class polyCollection  ⍝ Makes named collections of polyominoes

⍝ A colection is a name and 
⍝ a 3 column array volume, dimension and index into #.pdb.polyvoldim
⍝ and correspondin polyominod's 
⍝ and their color

    :field public name
    :field public voldimid
    :field public polyds
    :field public color  
   
    :include #.polyFns    ⍝Util                   

    ∇ new(namestring polyset)
    ⍝ Makes a collection of a set of polyominoes
      :Access Public
      :Implements Constructor  
     
      name←namestring
      voldimid←{⍵[⍋⍵;]}↑polyid¨∪polyset
      polyds←{⎕NEW #.polyominod(⍵)}¨↓voldimid
      color←↑polyds.filcol
      polyds←⍬
    ∇ 
    
     ∇ empty              ⍝ Make a dummy instance
      :Access Public
      :Implements Constructor 
      name←'Blank'
    ∇
    
    ∇ newx(namestring polydset dummy);vd;order;nodupix
     ⍝ New collection from polyominod's. Duplicates removed.
      :Access Public 
      :Implements Constructor 
     
      name←namestring
      vd←polydset.(vol dim index)
      order←⍋↑vd
      vd←vd[order]
      nodupix←1,2≢/vd
      voldimid←↑nodupix/vd
      polyds←nodupix/polydset[order]
      color←↑polyds.filcol
      polyds←⍬
    ∇
    
    ∇ refresh
     ⍝ Refresh existing collection
      :Access Public 
      polyds←{⎕NEW #.polyominod(⍵)}¨↓voldimid
      color←↑polyds.filcol
      polyds←⍬
    ∇
    
    ∇ addcolor
    ⍝ Set the color field on existing collection
      :Access Public 
      ⍝ polyds←{⎕NEW #.polyominod(⍵)}¨↓voldimid
      color←↑polyds.filcol
      polyds←⍬
    ∇

    ∇ res←polyominoes          ⍝ Retreives polyominos from library
      :Access Public 
     
      res←{(¯1↑⍵)pvd 2↑⍵}¨↓voldimid
    ∇
     
    ∇ res←assubcollections
      :Access Public 
     
      res←subcollections voldimid
    ∇

    ∇ res←numsubcollections
      :Access Public 
     
      res←↑{(name)(⍵[0;0])(⍵[0;1])(⍵[;2])}¨↑¨2∘↑eqc↓voldimid
    ∇

      polyid←{⍝ Find volume dimension and index of a single polyomino
          vol dim←⍴⍵
          ix←(pvd vol dim)⍳⊂⍵
          vol dim ix
      }
         
      subcollections←{⍝ Splits collection array in subcollection on each vol dim
          ↑{(name)(⍕⍵[0;0])(⍕⍵[0;1])(⍕⍵[;2])(⍕⊃⍴⍵[;2])}¨↑¨2∘↑eqc↓⍵
      }
        
:endclass  ⍝ collection
    
