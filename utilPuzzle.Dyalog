   :class utilPuzzle    ⍝ Instances in pbd.puzzleCollection
    :Access Public

        :field Public name
        :field Public pieces
        :field Public collectionname
        :field Public boxdim
        :field Public boxname 
        :field Public date  
        
     
        
        ∇ clone frompuzzle
          :Access Public
          :Implements Constructor
         
          name collectionname boxdim boxname date←frompuzzle.(name collectionname boxdim boxname date)
          pieces←{⎕NEW piece(⍵)}¨frompuzzle.pieces
        ∇ 
        
        ∇ empty              ⍝ Make a dummy instance
        :Access Public
        :Implements Constructor 
         name←'Blank'
        ∇

                 

    :class piece     ⍝ single piece of the collection
    
        :field Public polyd←⍬
        :field Public number←0
        :field Public polyomino 
        :field Public vol
        :field Public dim
        :field Public globalid   
        :field Public count←1
        :field Public rights←0                      ⍝ number of right chiral
        :field Public lefts←0                       ⍝ number of left chiral
        :field Public mirror←0
        :field Public pivot←0
        :field Public placements←⍬ 
        :field Public boxdim
        :field Public ldim                         ⍝ lifted  dim 
        :field Public chiral                       ⍝ Indicator for chirality
        
  

        ∇ res←allvalues
          :Access Public
         
          res←boxdim chiral count dim globalid ldim lefts mirror number pivot placements polyd polyomino rights vol
        ∇
        
        ∇ clone frompiece
          :Access Public
          :Implements Constructor
         
          boxdim chiral count dim globalid ldim lefts←7↑frompiece.allvalues
          mirror number pivot placements polyd polyomino rights vol←7↓frompiece.allvalues
        ∇
         
        ∇ empty              ⍝ Make a dummy instance
         :Access Public
         :Implements Constructor 
          vol←0
        ∇
        
        ∇ res←farve
          :Access Public
          ⍝ res←polyd.filcol
          res←polyd
        ∇
                                     
    :endClass ⍝-------------- end  piece ---------    
                             
    
:EndClass
