(use-trait ft-trait .trait-sip-010.sip-010-trait)

(define-trait DispatcherInterface 
    (
        (swap 
            ;; ({poolType: uint, swapFuncType: uint, fromToken: <ft-trait>, toToken: <ft-trait>, weightX: uint, weightY: uint, dx: uint, minDy: (optional uint)})
            (uint uint <ft-trait> <ft-trait> uint uint uint (optional uint))
            (response {dx: uint, dy: uint} uint)
        )
    )
)