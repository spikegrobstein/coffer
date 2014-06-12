module Coffer
  module Coin
    class Mincoin < Coffer::Definition
      git_repo 'https://github.com/mincoin/mincoin.git'
      home_page 'https://mincoin.io'
      symbol :MNC
      wallet_executable 'mincoind'
      directory 'Mincoin'
      config_file 'mincoind.conf'
    end
  end
end
