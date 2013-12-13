sl_tweet
========
sl コマンドが走る度に呟きます。

## Usage
Rubyのインストールが必要です。  
Ruby2.0での動作を確認していますが、1.9系でも動くと思います。  
1.8系で動かしたかったら修正して下さい。
Rubyからslコマンドを呼び出しているので、別途slコマンドのインストールも必要です。  
ディストリビューションのパッケージマネージャからインストールするか、各自ビルドして下さい。  
[mtoyoda/sl](https://github.com/mtoyoda/sl)

```sh
$ cd
$ git clone https://github.com/pocke/sl_tweet.git sl

// bundlerを使用する場合(推奨)
$ gem install bundler
$ cd sl
$ bundle install --path vendor/bundle

// bundlerを使用しない場合
$ gem install twitter oauth

$ echo 'alias sl="ruby ~/sl/sl.rb"' >> ~/.bashrc
$ source ~/.bashrc
$ sl
```
初回のslコマンド起動時に、OAuth認証をします。表示されたURLからPINコードを入手して入力して下さい。  
.bashrcの部分は適宜読み替えて下さい。
インストールするパスも気に食わなかったら別のところでどうぞ。

Copyright &copy; 2013 pocke
Licensed [MIT][mit]
[MIT]: http://www.opensource.org/licenses/mit-license.php
