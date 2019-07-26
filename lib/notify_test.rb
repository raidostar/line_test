require 'line_notify'

TOKEN= 'xmFj7d0G95unqtddMopRCLpeFwJ7iuso29LLXaH1q3n'
line_notify = LineNotify.new(TOKEN)
options = {
  message: 'this is from Rails',
  stickerPackageId: 1,
  stickerId: 139
}
line_notify.send(options)