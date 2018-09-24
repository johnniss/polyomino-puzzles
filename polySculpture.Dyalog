:Class polySculpture  ⍝ Makes named polyominod as a sculpture


    :field public name    
    :field public polyd 
    :field public date  
   
    :include #.polyFns    ⍝Util                   

    ∇ new(namestring polydx)
      :Access Public
      :Implements Constructor  
     
      name←namestring
      polyd←polydx
      date←6↑⎕TS
    ∇
    
    ∇ res←aspolyBox
      :Access Public
     
      res←#.⎕NEW #.polyBox(name polyd.polyomino)
    ∇ 
    
      ∇ z←export ⍝ New from old pdb.sculpture
      :Access Public
       
      name date polyd.( theta phi R vol dim polyomino (↑polycols)(↑filcol) cellcolors) 
    ∇ 
    

:endclass 
    
