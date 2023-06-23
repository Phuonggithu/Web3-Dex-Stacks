(use-trait ft-trait .trait-sip-010.sip-010-trait)




(define-constant DEX_TYPE_ALEX u301)

(define-constant ERR_FROM_TOKEN_NOT_MATCH (err u9001))


(define-public (swap (dexType uint) (poolId uint) (swapFuncId uint) (fromToken <ft-trait>) (toToken <ft-trait>) (weightX uint) (weightY uint) (dx uint) (minDy (optional uint))) 
    (let
        (
            (dy (if (is-eq DEX_TYPE_ALEX dexType)
                    (get dy (try! (contract-call? .alexAdapter swapAlex poolId swapFuncId fromToken toToken weightX weightY dx minDy)))
                    u0
                )
            )
        ) 
        

        (ok {dx: dx, dy: dy})
    )
)

