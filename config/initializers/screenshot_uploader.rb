if Rails.env.development?
Thread.new do
    system("python #{Rails.root.join('scripts/screenshot_uploader.py')}")
end
end