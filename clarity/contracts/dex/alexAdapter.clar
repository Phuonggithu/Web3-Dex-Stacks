

(use-trait ft-trait .trait-sip-010.sip-010-trait)

(define-constant ERR_FROM_TOKEN_NOT_MATCH (err u9001))
(define-constant ERR_POOL_NOT_EXISTS (err u9002))
(define-constant ERR_TO_TOKEN_NOT_MATCH (err u9003))
(define-constant ERR_WEIGHT_SUM (err u9004))

(define-constant ONE_8 u100000000) ;; 8 decimal places




(define-constant SWAP_ALEX_FOR_Y u101)
(define-constant SWAP_Y_FOR_ALEX u102)
(define-constant SWAP_WSTX_FOR_Y u103)
(define-constant SWAP_Y_FOR_WSTX u104)

(define-constant FIXED_WEIGHT u201)
(define-constant STABLE_POOL u202)

(define-public (swapAlex (poolId uint) (swapFuncId uint) (fromToken <ft-trait>) (toToken <ft-trait>) (weightX uint) (weightY uint) (dx uint) (minDy (optional uint))) 
    (let 
        (
            (dy (if (is-eq FIXED_WEIGHT poolId)
                    (if (is-eq SWAP_ALEX_FOR_Y swapFuncId)
                        (get dy (try! (handleSwapAlexForYFixed fromToken toToken weightX weightY dx minDy)))
                        (if (is-eq SWAP_Y_FOR_ALEX swapFuncId)
                            (get dx (try! (handleSwapYForAlexFixed fromToken toToken weightX weightY dx minDy)))
                            (if (is-eq SWAP_WSTX_FOR_Y swapFuncId)
                                u0
                                (if (is-eq SWAP_Y_FOR_WSTX swapFuncId)
                                    u0
                                    u0
                                )
                            )
                        )
                    )
                    u0
                )
            )
        )
        (ok {dx: u0, dy: dy})
    )
)

(define-private (handleSwapAlexForYFixed (fromToken <ft-trait>) (toToken <ft-trait>) (weightX uint) (weightY uint) (dx uint) (minDy (optional uint))) 
    (let
        (
            (fromTokenAddr (contract-of fromToken))
            (toTokenAddr (contract-of toToken))
            (alexTokenAddr .age000-governance-token)
        )
        (asserts! (is-eq (+ weightX weightY) ONE_8) ERR_WEIGHT_SUM)
        ;; check fromToken == alex
        (asserts! (is-eq alexTokenAddr fromTokenAddr) ERR_FROM_TOKEN_NOT_MATCH)
        ;; check pool exists
        (asserts! (is-some (contract-call? .fixed-weight-pool-alex get-pool-exists alexTokenAddr toTokenAddr weightX weightY)) ERR_POOL_NOT_EXISTS)
        ;; contract call do the real swap
        (contract-call? .fixed-weight-pool-alex swap-alex-for-y toToken weightY dx minDy)
    )
)

(define-private (handleSwapYForAlexFixed (fromToken <ft-trait>) (toToken <ft-trait>) (weightX uint) (weightY uint) (dx uint) (minDy (optional uint))) 
    (let
        (
            (fromTokenAddr (contract-of fromToken))
            (toTokenAddr (contract-of toToken))
            (alexTokenAddr .age000-governance-token)
        )
        (asserts! (is-eq (+ weightX weightY) ONE_8) ERR_WEIGHT_SUM)

        ;; check fromToken == alex
        (asserts! (is-eq alexTokenAddr toTokenAddr) ERR_TO_TOKEN_NOT_MATCH)
        ;; check pool exists
        (asserts! (is-some (contract-call? .fixed-weight-pool-alex get-pool-exists alexTokenAddr fromTokenAddr weightX weightY)) ERR_POOL_NOT_EXISTS)
        ;; contract call do the real swap
        (contract-call? .fixed-weight-pool-alex swap-y-for-alex fromToken weightY dx minDy)
    )
)
