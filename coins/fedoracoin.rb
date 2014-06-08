module Coffer
  module Coin
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

