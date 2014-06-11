module Coffer
  module Coin
    class Bottlecaps < Coffer::Definition
      git_repo 'https://github.com/bottlecaps-foundation/bottlecaps.git'
      home_page 'https://cryptocointalk.com/forum/242-bottlecaps-cap/'
      symbol :CAP
      wallet_executable 'bottlecapsd'
      directory 'BottleCaps'
      config_file 'BottleCaps.conf'
    end
  end
end
