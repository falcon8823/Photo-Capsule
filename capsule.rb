# coding: utf-8

require 'sinatra'
require 'sinatra/reloader' if development?
require 'haml'
require 'RMagick'
require 'zipruby'

PUBLIC_PATH = File.expand_path 'public', File.dirname(__FILE__)
ORIGINS_PATH = PUBLIC_PATH + '/originals/'
THUMBS_PATH = PUBLIC_PATH + '/thumbnails/'
PREVIEWS_PATH = PUBLIC_PATH + '/previews/'
ZIP_PATH = PUBLIC_PATH + '/zips/'

set :public_folder, PUBLIC_PATH
set :haml, format: :html5

# ファイル一覧
def exist_images(album_name)
	Dir.glob(ORIGINS_PATH + album_name + '/*.JPG').map{|f| File.basename f}.sort
end

def create(album_name, outpath, width)
	# ディレクトリ（アルバム）の存在チェック
	unless File.exist?(ORIGINS_PATH + album_name)
		raise 'Album is not exist'
	else
		dirname = outpath + album_name
		# サムネイルディレクトリが無ければ作成
		Dir::mkdir dirname unless File.exist?(dirname)
	end
	# 写真ファイル名リスト
	file_list = exist_images(album_name)

	file_list.each do |f|
		# サムネイルのパス
		orig_path = ORIGINS_PATH + album_name + '/' + f
		thumb_path = outpath + album_name + '/' + f

		# サムネイルが存在しない場合は作成
		unless File.exist?(thumb_path)
			# 縮小して保存
			thumb = Magick::Image.read(orig_path).first
			thumb.sample! width, width.to_f / thumb.columns * thumb.rows
			thumb.write(thumb_path)
		end
	end
end

# 存在するアルバムリスト
def exist_albums
	a = []
	Dir::foreach(ORIGINS_PATH) do |f|
		next if f == '.' or f == '..'
		if ORIGINS_PATH =~ /\/$/
			f = ORIGINS_PATH + f
		else
			f = ORIGINS_PATH + '/' + f
		end

		a << File.basename(f) if FileTest::directory?(f)
	end
	
	a.sort!
end

# トップページ
get '/' do
	@albums = exist_albums
	
	haml :home
end

# 各アルバムページ
get '/albums/:album_name' do
	@album_name = params[:album_name]
	@albums = exist_albums
	
	# ディレクトリ（アルバム）の存在チェック
	unless File.exist?(ORIGINS_PATH + @album_name)
		return status 404
	end

	create(@album_name, THUMBS_PATH, 160)
	create(@album_name, PREVIEWS_PATH, 520)

	@img_list = exist_images(@album_name)

	haml :index
end

# アルバムの写真をダウンロード
post '/albums/:album_name/download' do
	# 何もファイルが選択されていない場合
	if params[:files].nil?
		return 'ファイルを選択してね'
	end

	files = params[:files].map{|f| f[1]}
	@album_name = params[:album_name]
	files_path = files.map{|f| ORIGINS_PATH + "#{@album_name}/" + f}
	
	# ファイル名をソートして連結した文字列をキーとし
	# その文字列のMD5値をZIPファイル名にする
	zipname = 'photos-' +
		/^.{8}/.match(Digest::MD5.new.update(files_path.sort.join(' ')).to_s)[0] + '.zip'
	zippath = ZIP_PATH + @album_name + '/' + zipname
	
	# ファイルが存在しない場合作成
	unless File.exist? zippath
		begin
			dirname = File.dirname(zippath)
			unless File.exist?(dirname)
				Dir::mkdir dirname
			end
			Zip::Archive.open zippath, Zip::CREATE, Zip::NO_COMPRESSION do |zip|
				files_path.each do |f|
					zip.add_file f
				end
			end
		rescue
			status 500
		end
	end
	
	# リダイレクト
	redirect URI.encode("/zips/#{@album_name}/#{zipname}")
end
