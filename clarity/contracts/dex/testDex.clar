
;; prepare the deployment
;; 0. deployer, wallet_1
;; 1. mint usdaToken, usdaToken.mintFixed(deployer, deployer.address, 100000000 * ONE_8)
;; 2. mint wbtcToken, wbtcToken.mintFixed(deployer, deployer.address, 100000 * ONE_8);
;; 3. mint alexToken, alexToken.mintFixed(deployer, deployer.address, 100000000 * ONE_8);

;; const price = 50000;
;; const quantity = 10 * ONE_8;
;; 4. createPool alex-usda simple-weight-pool-alex.createPool(deployer, alex, usda, fwpaddr, multi, quantity*price, quantity*price)
;; 5. createPool alex-wbtc simple-weitht-pool-alex.createPool(deployer, alex, wbtc, fwpaddr, multi, quantity*price, quantity)
;; 6. setMaxInRatio simple-equation.set-max-in-ratio 0.3e8
;; 7. setMaxOutRatio simple-equation.set-max-out-ratio 0.3e8
;; 8. setStartBlock simple-weight-pool-alex.set-start-block(deployer,alex,usda,0)
;; 8. setStartBlock simple-weight-pool-alex.set-start-block(deployer,alex,wbtc,0)




(define-constant deployer  'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE)
(define-constant user  'ST1J4G6RR643BCG8G8SR6M2D9Z9KXT2NJDRK3FBTK)
(define-constant ONE_8 u100000000) ;; 8 decimal places

(define-constant quantity (* u10 ONE_8))
(define-constant price u50000)

(define-constant MAX_IN_RATIO u30000000)
(define-constant MAX_OUT_RATIO u30000000)

(use-trait ft-trait .trait-sip-010.sip-010-trait)

(define-public (setUp) 
    (begin 
        (try! (contract-call? .token-usda mint-fixed (* u100000000 ONE_8) deployer))
        (try! (contract-call? .token-xbtc mint-fixed (* u100000 ONE_8) deployer))
        (try! (contract-call? .age000-governance-token mint-fixed (* u100000000 ONE_8) deployer))


        (try! (contract-call? .token-usda mint-fixed (* u100000000 ONE_8) user))
        (try! (contract-call? .token-xbtc mint-fixed (* u100000 ONE_8) user))
        (try! (contract-call? .age000-governance-token mint-fixed (* u100000000 ONE_8) user))


        ;; simple weight pools - stable pool : usda-alex alex-xbtc
        (try! (contract-call? .simple-weight-pool-alex create-pool .age000-governance-token .token-usda .fwp-alex-usda .multisig-fwp-alex-usda (* quantity price) (* quantity price)))
        (try! (contract-call? .simple-weight-pool-alex create-pool .age000-governance-token .token-xbtc .fwp-alex-wbtc-50-50 .multisig-fwp-alex-wbtc-50-50 (* quantity price) (* quantity u1)))



        ;; fixed weight pools usda-wstx wstx-xbtc
        (try! (contract-call? .fixed-weight-pool-v1-01 create-pool .token-wstx .token-usda u50000000 u50000000 .fwp-wstx-usda-50-50-v1-01 .multisig-fwp-wstx-usda-50-50-v1-01 (* quantity price) (* quantity price)))
        (try! (contract-call? .fixed-weight-pool-v1-01 create-pool .token-wstx .token-xbtc u50000000 u50000000 .fwp-wstx-wbtc-50-50-v1-01 .multisig-fwp-wbtc-usda-50-50-v1-01 (* quantity price) (* quantity u1)))



        (try! (contract-call? .simple-equation set-max-in-ratio MAX_IN_RATIO))
        (try! (contract-call? .simple-equation set-max-out-ratio MAX_OUT_RATIO))

        (try! (contract-call? .simple-weight-pool-alex set-start-block .age000-governance-token .token-usda u0))
        (try! (contract-call? .simple-weight-pool-alex set-start-block .age000-governance-token .token-xbtc u0))
        ;; (try! (contract-call? .swap-helper-v1-01 swap-helper .token-usda .token-xbtc ONE_8 none))
        ;; (try! (contract-call? .swap-helper-v1-01 swap-helper .token-usda .token-wstx ONE_8 none))
        (try! (setUp2))
        (ok true)
    )
)
(define-public (setUp2) 
    (begin
        (try! (contract-call? .usda-token mint-for-dao u10000 deployer))
        (try! (contract-call? .wrapped-stx-token mint-for-dao u10000 deployer))

        (try! (contract-call? .arkadiko-swap-v2-1 create-pair .wrapped-stx-token .usda-token .arkadiko-swap-token-wstx-usda "" u1000 u3000))
        (ok true)
    )
)
(begin
    (setUp)
)
(define-constant DEX_TYPE_ALEX u301)
(define-constant SWAP_ALEX_FOR_Y u1000001)
(define-constant SWAP_Y_FOR_ALEX u1000002)
(define-constant SWAP_WSTX_FOR_Y u1000003)
(define-constant SWAP_Y_FOR_WSTX u1000004)

(define-constant FIXED_WEIGHT u2000001)
(define-constant STABLE_POOL u2000002)

(define-public (test_swapAlex0) 
    (let
        (
            (weightUSDA u50000000)
            (weightWSTX u50000000)
            (amount u10000000)
        ) 
        ;; swap usda for wstx through fixed weight pool
        (try! (contract-call? .aggregator unxswap 
            {fromToken: .token-usda, 
            toToken: .token-wstx, 
            isNative: false,
            fromTokenAmount: amount, 
            minReturnAmount: u0}
            (list 
                {adapterImpl: .alexAdapter, 
                poolType: FIXED_WEIGHT, 
                swapFuncType: SWAP_Y_FOR_WSTX, 
                fromToken: none, 
                toToken: none, 
                fromTokenAlex:(some .token-usda), 
                toTokenAlex: (some .token-wstx), 
                weightX: weightUSDA, 
                weightY: weightWSTX, 
                factor: u0,
                dx: amount, 
                minDy: none,
                rate: u1,
                isMul: true}
            )
        ))
        (ok true)
    )
)

(define-public (test_swapAlex1) 
    (let
        (
            (weight u50000000)
            (amount u1000000000)
        ) 
        ;; swap usda for wstx through fixed weight pool
        (try! (contract-call? .aggregator unxswap 
            {fromToken: .token-usda, 
            toToken: .token-xbtc, 
            isNative: false,
            fromTokenAmount: amount, 
            minReturnAmount: u0}
            (list 
                {adapterImpl: .alexAdapter, 
                poolType: FIXED_WEIGHT, 
                swapFuncType: SWAP_Y_FOR_WSTX, 
                fromToken: none, 
                toToken: none, 
                fromTokenAlex:(some .token-usda), 
                toTokenAlex: (some .token-wstx), 
                weightX: weight, 
                weightY: weight, 
                factor: u0,
                dx: amount, 
                minDy: none,
                rate: u1,
                isMul: true}
                {adapterImpl: .alexAdapter, 
                poolType: FIXED_WEIGHT, 
                swapFuncType: SWAP_WSTX_FOR_Y, 
                fromToken: none, 
                toToken: none, 
                fromTokenAlex:(some .token-wstx), 
                toTokenAlex: (some .token-xbtc), 
                weightX: weight, 
                weightY: weight, 
                factor: u0,
                dx: amount, 
                minDy: none,
                rate: u1,
                isMul: true}
            )
        ))
        (ok true)
    )
)

(define-constant SWAP_X_FOR_Y    u1000005)
(define-constant SWAP_Y_FOR_X    u1000006)

(define-public (test_swapArkadiko) 
    (let
        (
            (weight u0)
            (amount u1000)
        ) 
        ;; swap usda for wstx through fixed weight pool
        (try! (contract-call? .aggregator unxswap 
            {fromToken: .usda-token, 
            toToken: .wrapped-stx-token, 
            isNative: true,
            fromTokenAmount: amount, 
            minReturnAmount: u249}
            (list 
                {adapterImpl: .arkadAdapter, 
                poolType: FIXED_WEIGHT, 
                swapFuncType: SWAP_Y_FOR_X, 
                fromToken: (some .usda-token), 
                toToken: (some .wrapped-stx-token), 
                fromTokenAlex:none, 
                toTokenAlex: none, 
                weightX: u0, 
                weightY: u0, 
                factor: u0,
                dx: amount, 
                minDy: none,
                rate: u1,
                isMul: true}
            )
        ))
        (ok true)
    )
)

(define-public (test_swapArkadiko1) 
    (let
        (
            (weight u0)
            (amount u1000)
        ) 
        ;; swap usda for wstx through fixed weight pool
        (try! (contract-call? .aggregator unxswap 
            {
            fromToken: .wrapped-stx-token, 
            toToken: .usda-token, 
            isNative: false,
            fromTokenAmount: amount, 
            minReturnAmount: u0}
            (list 
                {adapterImpl: .arkadAdapter, 
                poolType: FIXED_WEIGHT, 
                swapFuncType: SWAP_X_FOR_Y, 
                fromToken: (some .wrapped-stx-token), 
                toToken: (some .usda-token), 
                fromTokenAlex:none, 
                toTokenAlex: none, 
                weightX: u0, 
                weightY: u0, 
                factor: u0,
                dx: amount, 
                minDy: none,
                rate: u1,
                isMul: true}
            )
        ))
        (ok true)
    )
)

(define-public (test_rate) 
    (let
        (
            (weight u50000000)
            (amount u1000)
        ) 
        ;; swap usda for wstx through fixed weight pool
        (try! (contract-call? .aggregator unxswap 
            {fromToken: .usda-token, 
            toToken: .token-usda, 
            isNative: false,
            fromTokenAmount: amount, 
            minReturnAmount: u0}
            (list 
                {adapterImpl: .arkadAdapter, 
                poolType: FIXED_WEIGHT, 
                swapFuncType: SWAP_Y_FOR_X, 
                fromToken: (some .usda-token), 
                toToken: (some .wrapped-stx-token), 
                fromTokenAlex:none, 
                toTokenAlex: none, 
                weightX: u0, 
                weightY: u0, 
                factor: u0,
                dx: amount, 
                minDy: none,
                rate: ONE_8,
                isMul: true}
                {adapterImpl: .alexAdapter, 
                poolType: FIXED_WEIGHT, 
                swapFuncType: SWAP_WSTX_FOR_Y, 
                fromToken: none, 
                toToken: none, 
                fromTokenAlex:(some .token-wstx), 
                toTokenAlex: (some .token-usda), 
                weightX: weight, 
                weightY: weight, 
                factor: u0,
                dx: amount, 
                minDy: none,
                rate: u1,
                isMul: true}
            )
        ))
        (ok true)
    )
)