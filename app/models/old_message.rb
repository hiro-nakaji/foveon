class OldMessage < ActiveRecord::Base
  establish_connection :foveon
  self.table_name = 'tb_bbs'
  acts_as_tree order: 'lastupdate'

  # Return Hash for a 'Message'
  #
  # @return Hash
  def message_hash
    salt = [rand(64), rand(64)].pack("C*").tr("\x00-\x3f", "A-Za-z0-9./")
    pswd = self.password.present? ?  self.password : ''
    homepage = self.url
    homepage = "http://" + homepage unless homepage.blank? || homepage.start_with?('http')
    ctypted_password = pswd.crypt(salt)
    {
      old_id:         self.id,
      created_at:     self.lastupdate,
      updated_at:     self.lastmodified,
      author:         self.author,
      mail:           self.mailaddr,
      homepage:       homepage,
      title:          self.title,
      content:        self.data,
      remote_address: self.address,
      password:       ctypted_password,
      message_type:  'text'
    }
  end
end