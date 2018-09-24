:Class utilSculpture  ⍝ Makes named polyominod as a sculpture


    :field public name 
    :field public date
    :field public vol 
    :field public dim 
    :field public theta 
    :field public phi 
    :field public R  
    :field public polyomino 
    :field public polycols
    :field public filcol 
    :field public cellcolors 
   
    ⍝ :include #.polyFns                     

    ∇ new(namestring polydx)
      :Access Public
      :Implements Constructor  
     
      name←namestring
      polyd←polydx
      date←6↑⎕TS
    ∇ 
    
    ∇ newfrom(old) ⍝ New from old pdb.sculpture
      :Access Public
      :Implements Constructor 
       
      name date←old.(name date )
      theta phi R vol dim ←old.polyd.(theta phi R vol dim )  
      polyomino polycols filcol cellcolors←old.polyd.(polyomino (↑polycols)(↑filcol) cellcolors) 
    ∇ 
    
     ∇ empty              ⍝ Make a dummy instance
      :Access Public
      :Implements Constructor 
      name←'Blank'
    ∇
    
    ∇ res←aspolyBox
      :Access Public
     
      res←#.⎕NEW #.polyBox(name polyomino)
    ∇
    

:endclass   
