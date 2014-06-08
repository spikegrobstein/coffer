require 'pry'

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

    class Auroracoin < Coffer::Definition

      git_repo 'https://github.com/baldurodinsson/auroracoin-project.git'

      home_page 'http://auroracoin.org'

      symbol :AUR

      wallet_executable 'auroracoind'
      directory 'auroracoin'
      config_file 'auroracoin.conf'

    end

    class Fedoracoin < Coffer::Definition

      home_page 'http://fedoraco.in'
      git_repo 'https://github.com/fedoracoin/fedoracoin.git'

      symbol :TIPS

      wallet_executable 'fedoracoind'
      directory 'fedoracoin'
      config_file 'fedoracoin.conf'

    end

  end
end

Coffer::Registry.load :feathercoin
Coffer::Registry.load :auroracoin
Coffer::Registry.load :fedoracoin

