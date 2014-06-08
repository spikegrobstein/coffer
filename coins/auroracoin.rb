module Coffer
  module Coin
    class Auroracoin < Coffer::Definition

      git_repo 'https://github.com/baldurodinsson/auroracoin-project.git'

      home_page 'http://auroracoin.org'

      symbol :AUR

      wallet_executable 'auroracoind'
      directory 'auroracoin'
      config_file 'auroracoin.conf'

    end
  end
end

