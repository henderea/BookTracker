require 'base64'

class HtmlEmail
  def initialize
    @rand = Random.new
    @boundary = "#{@rand.rand(0..9)}-#{@rand.rand(10000000000..9999999999)}-#{@rand.rand(10000000000..9999999999)}=:#{@rand.rand(10000..99999)}"
    @header = "MIME-Version: 1.0\nContent-Type: multipart/mixed; boundary=\"#{@boundary}\"\n"
    @message = "--#{@boundary}\nContent-type:text/html;charset=iso-8859-1\n"
    @attachments = ''
  end

  def unique_id
    OpenSSL::Digest::MD5.hexdigest("#{@rand.rand}#{DateTime::now.strftime('%Q')}")
  end

  def add_attachment(data, mime_type, file_name)
    @attachments << "--#{@boundary}\n"
    @attachments << "Content-Type: #{mime_type}; name=\"#{file_name}\"\n"
    @attachments << "Content-Disposition: attachment; filename=\"#{file_name}\"\n"
    @attachments << "Content-Transfer-Encoding: base64\n\n"
    @attachments << Base64.encode64(data)
    @attachments << "\n"
  end

  def add_inline_image(data, mime_type, file_name)
    file_name = file_name.gsub(/ /, '')
    cid = "#{file_name[0...file_name.index('.')]}#{unique_id}"
    @attachments << "--#{@boundary}\n"
    @attachments << "Content-Type: #{mime_type}; name=\"#{file_name}\"\n"
    @attachments << "Content-ID: <#{cid}>\n"
    @attachments << "Content-Disposition: inline; filename=\"#{file_name}\"\n"
    @attachments << "Content-Transfer-Encoding: base64\n\n"
    @attachments << Base64.encode64(data)
    @attachments << "\n"
  end

  def <<(str)
    @message << str
  end

  def build_email(to, from, subject, cc = nil, bcc = nil)
    msg = "#{@header}"
    msg << "Subject: #{subject}\n"
    msg << "From: #{from}\n"
    msg << "To: #{to}\n"
    msg << "Cc: #{cc}\n" unless cc.nil? || cc.empty
    msg << "Bcc: #{bcc}\n" unless bcc.nil? || bcc.empty
    msg << "\n\n#{@message}\n"
    msg << "\n#{@attachments}\n" unless @attachments.nil? || @attachments.empty?
    msg << "--#{@boundary}\n\n"
    msg
  end
end