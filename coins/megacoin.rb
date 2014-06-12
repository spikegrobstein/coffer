module Coffer
  module Coin
    class Megacoin < Coffer::Definition
      git_repo 'https://github.com/megacoin/megacoin.git'
      home_page 'http://megacoin.co.nz'
      symbol :MEC
      wallet_executable 'megacoind'
      directory 'Megacoin'
      config_file 'megacoin.conf'
    end
  end
end
