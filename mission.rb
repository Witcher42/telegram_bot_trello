# encoding: utf-8
require 'telegram/bot'
require 'json'
require 'uri'
require '/root/bot/json_save.rb'
token = '149132564:AAGfWod2JwfYW1pbO7q9jciWSN1oEMN3nzg'
incompleteLabels = ['5666779e19ad3a5dc26426a5','57287baf9148b133b928f6da','56d4fd5d152c3f92fd3a75c7','574c64565b9b3323fb39a5bd']

begin
  Telegram::Bot::Client.run(token, logger: Logger.new($stderr)) do |bot|
		bot.logger.info('Bot has been started')
		bot.listen do |message|
			begin
				next if message.date < (Time.now - 60).to_i
				case message.text
					when /\/q ./
						s_mission_title = message.text.sub(/\/q / , "").downcase.to_s
						next if s_mission_title == '[' || s_mission_title == ']'
						trello = open('/root/bot/ingress-medal-arts.json').read
						if trello.nil?
							bot.api.send_message(chat_id: message.chat.id, text: "出错辣,豆腐丝快粗来化身水管道工人") 
							next
						end
						json = JSON.parser.new(trello)
						hash =  json.parse()
						mission_title = Array.new
						uniq_title = Array.new
						cards_hash = hash['cards']
						result =''
						cover_url = ''
						cards_hash.each_with_index { |value,key |
							target_name = value['name'].downcase.to_s
							if (target_name == s_mission_title) && (value['closed'] != true)
								mission_title[0] = key
								break
							elsif (target_name.include?(s_mission_title)) && (value['closed'] != true)
								mission_title.push(key)
							end
						}

						bot.api.send_message(chat_id: message.chat.id, text: "任务已找到,请稍候喔~") if !mission_title.empty?
						if !mission_title.empty? && mission_title.length > 1
							mission_title.each_with_index do |id,key|
								uniq_title.push([cards_hash[id]['name'],cards_hash[id]['idLabels']])
							end
							uniq_title = uniq_title.uniq{|item|item.first}
							uniq_title.each_with_index do |value,id|
								result << "/q #{value[0]}" if !value.nil?
								#result << "#{id}\n"
								result << ((incompleteLabels+value[1]).uniq! == nil ? "\n" : " (incomplete)\n")
							end
							bot.api.send_message(chat_id: message.chat.id, text: "喏,一共有这么多任务,你要看哪一个呢: \n#{result}")
						elsif mission_title.length == 1
							result << "任务名:#{cards_hash[mission_title[0]]['name']}"
							result << ((incompleteLabels+cards_hash[mission_title[0]]['idLabels']).uniq! == nil ? "\n" : " (incomplete)\n")
							result << "任务描述: #{cards_hash[mission_title[0]]['desc']} \n"
							result << "trello链接: [点我点我](#{cards_hash[mission_title[0]]['shortUrl']})\n"

							# if cards_hash[mission_title[0]]['name'].sub(/^\[.*\]/ , "")

							result << "ingressmm: [点我点我](#{URI::escape("http://ingressmm.com/?find=#{cards_hash[mission_title[0]]['name'].sub(/^\[.*\]( |)/ , "")}")})\n"
							result << "在[AQMH](http://imaq.cn/mh)中搜索:[点我点我](http://aqmh.azurewebsites.net/#q=#{URI::escape(cards_hash[mission_title[0]]['name'].sub(/^\[.*\]( |)/ , ""))})"
							if cards_hash[mission_title[0]]['idAttachmentCover'] != nil
								cards_hash[mission_title[0]]['attachments'].each do |attachment|
									if attachment['id'] == cards_hash[mission_title[0]]['idAttachmentCover']
										cover_url =  !attachment['previews'][4].nil? ? attachment['previews'][4]['url'] : attachment['url']
										break
									end
								end
								bot.api.send_photo(chat_id: message.chat.id,photo:cover_url,disable_notification:false)
							end
							bot.api.send_message(chat_id: message.chat.id, text: "#{result}" ,parse_mode:"Markdown", disable_web_page_preview: "true")
						else
							bot.api.send_message(chat_id: message.chat.id, text: "很抱歉没有查到你想找的任务信息~要不要换个姿势呢?")
						end
					when 'jiamin'
						bot.api.send_message(chat_id: message.chat.id, text: "整个艾泽拉斯都回响着你的名字，而我是多么幸运的一个家伙")
					when '/520'
						bot.api.send_message(chat_id: message.chat.id, text: "520.today")
					when /\/love ./
						#msg = message.text.sub(/\/h / , "").downcase.to_s
						bot.api.send_message(chat_id: message.chat.id, text: "你是整个世界,Jiamin")
					when '/q@today520_bot'
						bot.api.send_message(chat_id: message.chat.id, text: "查询任务格式为: /q 任务名\n（建议大家如果仅仅是搜索trello可以小窗bot，以免对群组成员造成垃圾信息骚扰）")
					end
			rescue 
				bot.api.send_message(chat_id: message.chat.id, text: "出错辣,豆腐丝已启动强大自我修复机制，一分钟后如果还自动修不好，再小窗豆腐丝 @tolves 哟") 
				uri = URI('https://trello.com/b/LvwOjrYP/ingress-medal-arts.json')
				save(uri)
				sleep(70)
				retry
			end
		end
	end
rescue 
  puts '又出错一次啦,人家先睡70s喔'		
  sleep(70)
  retry
end




