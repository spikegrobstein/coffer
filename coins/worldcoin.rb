module Coffer
  module Coin
    class Worldcoin < Coffer::Definition
      git_branch 'v0.8.6.2'
      git_repo 'https://github.com/worldcoinproject/worldcoin-v0.8.git'
      home_page 'http://www.worldcoinalliance.net'
      symbol :WDC
      wallet_executable 'worldcoind'
      directory 'Worldcoin'
      config_file 'worldcoin.conf'
    end
  end
end
