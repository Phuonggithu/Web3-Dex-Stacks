(use-trait ft-trait .sip-010-trait-ft-standard.sip-010-trait)
(use-trait ft-trait-alex .trait-sip-010.sip-010-trait)
(use-trait liquidity-token .liquidity-token-trait-v4c.liquidity-token-trait)

(define-trait DispatcherInterface 
    (
        (swap    
            ;; ({poolType: uint, swapFuncType: uint, fromToken: <ft-trait>, toToken: <ft-trait>, weightX: uint, weightY: uint,factor uint, dx: uint, minDy: (optional uint)})
            (uint uint (optional <ft-trait>) (optional <ft-trait>) (optional <ft-trait-alex>) (optional <ft-trait-alex>) (optional <liquidity-token>) uint uint uint uint (optional uint))
            (response {dy: uint} uint)
        )
    )
)
