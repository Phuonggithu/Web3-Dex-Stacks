
(impl-trait .dispatcherTrait.DispatcherInterface)

(use-trait ft-trait .trait-sip-010.sip-010-trait)

(define-constant ERR_FROM_TOKEN_NOT_MATCH (err u9001))
(define-constant ERR_POOL_NOT_EXISTS (err u9002))
(define-constant ERR_TO_TOKEN_NOT_MATCH (err u9003))
(define-constant ERR_WEIGHT_SUM (err u9004))

(define-constant ONE_8 u100000000) ;; 8 decimal places




(define-constant SWAP_ALEX_FOR_Y u1000001)
(define-constant SWAP_Y_FOR_ALEX u1000002)
(define-constant SWAP_WSTX_FOR_Y u1000003)
(define-constant SWAP_Y_FOR_WSTX u1000004)

(define-constant FIXED_WEIGHT u2000001)
(define-constant STABLE_POOL u2000002)

(define-public (swap (poolId uint) (swapFuncId uint) (fromToken <ft-trait>) (toToken <ft-trait>) (weightX uint) (weightY uint) (dx uint) (minDy (optional uint))) 
    (let 
        (
            (dy (if (is-eq FIXED_WEIGHT poolId)
                    (if (is-eq SWAP_ALEX_FOR_Y swapFuncId)
                        (get dy (try! (handleSwapAlexForYFixed fromToken toToken weightX weightY dx minDy)))
                        (if (is-eq SWAP_Y_FOR_ALEX swapFuncId)
                            (get dx (try! (handleSwapYForAlexFixed fromToken toToken weightX weightY dx minDy)))
                            (if (is-eq SWAP_WSTX_FOR_Y swapFuncId)
                                (get dy (try! (handleSwapWstxForYFixed fromToken toToken weightX weightY dx minDy)))
                                (if (is-eq SWAP_Y_FOR_WSTX swapFuncId)
                                    (get dx (try! (handleSwapYForWstxFixed fromToken toToken weightX weightY dx minDy)))
                                    u0
                                )
                            )
                        )
                    )
                    u0
                )
            )
        )
        (ok {dx: dx, dy: dy})
    )
)

(define-private (handleSwapAlexForYFixed (fromToken <ft-trait>) (toToken <ft-trait>) (weightFrom uint) (weightTo uint) (dx uint) (minDy (optional uint))) 
    (let
        (
            (fromTokenAddr (contract-of fromToken))
            (alexTokenAddr .age000-governance-token)
            (tokenY toToken)
            (weightY weightTo)
            (weightX (- ONE_8 weightY))
            (tokenYAddr (contract-of tokenY))
        )
        (asserts! (is-eq (+ weightFrom weightTo) ONE_8) ERR_WEIGHT_SUM)
        ;; check fromToken == wstx
        (asserts! (is-eq alexTokenAddr fromTokenAddr) ERR_FROM_TOKEN_NOT_MATCH)
        ;; check pool exists
        (asserts! (is-some (contract-call? .fixed-weight-pool-alex get-pool-exists alexTokenAddr tokenYAddr weightX weightY)) ERR_POOL_NOT_EXISTS)
        ;; contract call do the real swap
        (contract-call? .fixed-weight-pool-alex swap-alex-for-y tokenY weightY dx minDy)
    )
)

(define-private (handleSwapYForAlexFixed (fromToken <ft-trait>) (toToken <ft-trait>) (weightFrom uint) (weightTo uint) (dx uint) (minDy (optional uint))) 
    (let
        (
            (toTokenAddr (contract-of toToken))
            (alexTokenAddr .age000-governance-token)
            (tokenY fromToken)
            (weightY weightFrom)
            (weightX (- ONE_8 weightY))
            (tokenYAddr (contract-of tokenY))
        )
        (asserts! (is-eq (+ weightFrom weightTo) ONE_8) ERR_WEIGHT_SUM)
        ;; check fromToken == wstx
        (asserts! (is-eq alexTokenAddr toTokenAddr) ERR_TO_TOKEN_NOT_MATCH)
        ;; check pool exists
        (asserts! (is-some (contract-call? .fixed-weight-pool-alex get-pool-exists alexTokenAddr tokenYAddr weightX weightY)) ERR_POOL_NOT_EXISTS)
        ;; contract call do the real swap
        (contract-call? .fixed-weight-pool-alex swap-y-for-alex tokenY weightY dx minDy)
    )
)

(define-private (handleSwapWstxForYFixed (fromToken <ft-trait>) (toToken <ft-trait>) (weightFrom uint) (weightTo uint) (dx uint) (minDy (optional uint))) 
    (let
        (
            (fromTokenAddr (contract-of fromToken))
            (wstxTokenAddr .token-wstx)
            (tokenY toToken)
            (weightY weightTo)
            (weightX (- ONE_8 weightY))
            (tokenYAddr (contract-of tokenY))
        )
        (asserts! (is-eq (+ weightFrom weightTo) ONE_8) ERR_WEIGHT_SUM)
        ;; check fromToken == wstx
        (asserts! (is-eq wstxTokenAddr fromTokenAddr) ERR_FROM_TOKEN_NOT_MATCH)
        ;; check pool exists
        (asserts! (is-some (contract-call? .fixed-weight-pool-v1-01 get-pool-exists wstxTokenAddr tokenYAddr weightX weightY)) ERR_POOL_NOT_EXISTS)
        ;; contract call do the real swap
        (contract-call? .fixed-weight-pool-v1-01 swap-wstx-for-y tokenY weightY dx minDy)
    )
)

(define-private (handleSwapYForWstxFixed (fromToken <ft-trait>) (toToken <ft-trait>) (weightFrom uint) (weightTo uint) (dx uint) (minDy (optional uint))) 
    (let
        (
            (toTokenAddr (contract-of toToken))
            (wstxTokenAddr .token-wstx)
            (tokenY fromToken)
            (weightY weightFrom)
            (weightX (- ONE_8 weightY))
            (tokenYAddr (contract-of tokenY))
        )
        (asserts! (is-eq (+ weightFrom weightTo) ONE_8) ERR_WEIGHT_SUM)
        ;; check fromToken == wstx
        (asserts! (is-eq wstxTokenAddr toTokenAddr) ERR_TO_TOKEN_NOT_MATCH)
        ;; check pool exists
        (asserts! (is-some (contract-call? .fixed-weight-pool-v1-01 get-pool-exists wstxTokenAddr tokenYAddr weightX weightY)) ERR_POOL_NOT_EXISTS)
        ;; contract call do the real swap
        (contract-call? .fixed-weight-pool-v1-01 swap-y-for-wstx tokenY weightY dx minDy)
    )
)

