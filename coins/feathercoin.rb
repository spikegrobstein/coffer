module Coffer
  module Coin
    class Feathercoin < Coffer::Definition

      git_repo 'https://github.com/FeatherCoin/Feathercoin.git'

      home_page 'https://www.feathercoin.com'

      symbol :FTC

      wallet_executable 'feathercoind'

      directory 'feathercoin'

      config_file 'feathercoin.conf'

    end
  end
end

