module Coffer
  module Coin
    class Feathercoin < Coffer::CoinInstaller

      git_repo 'https://github.com/FeatherCoin/Feathercoin.git'

      requires 'boost'
      requires 'berkeley-db'

      wallet_executable 'feathercoind'

    end

  end
end

