

class ToolsService
    def self.random_string(num)
        o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
        (0...num).map { o[rand(o.length)] }.join
    end
end
