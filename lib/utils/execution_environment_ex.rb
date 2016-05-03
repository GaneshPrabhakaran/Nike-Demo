module BuildInfo
  siteInfo = 'Cannot determine site environment.'
  url = ExecutionEnvironment.url.sub('http://','')
  begin
    homepage = Net::HTTP.get(url, '/')
    if homepage == '' && url.start_with?('www.')
      homepage = Net::HTTP.get(url.sub!('www.', 'www1.'), '/')
    elsif homepage == '' && url.start_with?('www1.')
      homepage = Net::HTTP.get(url.sub!('www1.', 'www.'), '/')
    end
    tagid = 'flexLabelLink_'
    tagid = 'mainNav' if homepage.index(tagid).nil?
    i = homepage.index(tagid)
    (1..10).each do
      category_page = homepage
      i = category_page.index('href=', i) + 'href='.length + 1
      landing = category_page[i..category_page.index('>', i)-2]
      if landing.include?('.fds.com/')
        url = landing.split('.fds.com')
        landing = url[1]
        url = url[0].split('//')[1] + '.fds.com'
      else
        landing = landing.split('?')[0]
      end
      begin
        category_page = Net::HTTP.get(url, landing).to_s
        if category_page != ''
          k = category_page.index('</body>') + '</body>'.length
          category_page = category_page[k..category_page.index('</html>')-1]
          if category_page != ''
            siteInfo = category_page.split("\n").reject{|i| i.include?('-->') || i.include?('<!--') || i.blank?}.join("\n")
            break
          end
        end
      rescue
      end
      i = i + 'href='.length
    end
  rescue
  end

  # set the build number
  if ENV['RELEASE_VERSION'].nil?
    doc = Nokogiri::HTML(homepage)
    ENV['RELEASE_VERSION'] = doc.css("release").text
  end

  ENV['SITE_INFO'] = Time.new.strftime('Started on %m/%d/%Y %I:%M%p') + "\n" +
                     (ENV['JOB_NAME'].nil?? "":ENV['JOB_NAME'] + " ") + (ENV['BUILD_NUMBER'].nil?? "":ENV['BUILD_NUMBER'] + " ") + (ENV['BROWSERNAME'].nil?? "":ENV['BROWSERNAME'] + "firefox") + "\n" +
                      ExecutionEnvironment.url + "\n" + siteInfo
end
