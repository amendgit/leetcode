require 'fileutils'

class Problem
	attr_accessor :index, :title, :desciption, :acceptRate, :level
	
	def to_s 
		return sprintf("[%04d] %-60s %-6s (%7s)", @index, @title, @acceptRate, @level)
	end

	def from_s(s)
		@index      = s[ 1,  4].strip.to_i
		@title      = s[ 7, 60].strip
		@acceptRate = s[68,  6].strip
		@level      = s[76,  7].strip
	end
end

def fetchProblemList
	problems = `leetcode list -q d`.lines.map do |s| 
		problem = Problem.new
		problem.from_s(s[6..-1])
	end
	return problems
end

def saveProblemList()
	problems = fetchProblemList()
	fd = File.open('./problemlist.txt', 'w')
	problems.each do |problem|
		fd.puts(problem.to_s)
	end
	fd.close()
end

def loadProblemList
	problems = []
	File.read('./index.txt').lines.each do |s|
		problem = Problem.new
		problem.from_s(s)
		problems << problem
	end
	return problems
end

def fetchDescription(problemIndex) 
	return `leetcode show #{problemIndex}`
end

def solutionFilepath(problem)
	return sprintf("./problems/%04d.%s.md", problem.index, problem.title)
end

class Solution
	attr_accessor :problem, :question, :answer

	def to_s 
		s = <<EOS
#{ @problem.to_s }

<!--front-->	
#{ @question }
<!--back-->
#{ @answer }
EOS
		return s
	end

	def from_s(s)
		lines = s.lines
		problem = Problem.new
		problem.from_s(lines[0])
		@problem = problem
		l, h = 0, 0
		l += 1 while !lines[l].include?('<!--front-->')
		h += 1 while !lines[h].include?('<!--back-->')
		@question = lines[l+1..h-1].join()
		l, h = h+1, lines.length
		@answer = lines[l..h].join()
	end
end

def loadSolution(problem)
	filepath = solutionFilepath(problem)
	if !File.exists?(filepath)
		return nil
	end
	content = File.read(filepath)
	return content
end

def generateSolutionFiles()
	problems = loadProblemList()
	FileUtils.mkdir_p('./problems')
	problems.each do |problem|
		filepath = solutionFilepath(problem)
		if File.exists?(filepath)
			next
		end
		solution = Solution.new
		solution.problem = problem
		solution.question = fetchDescription(problem.index)
		content = solution.to_s
		File.write(filepath, content)
	end
end

def exportToCSV() 
	problems = loadProblemList()
	csv = File.open('./leetcode.csv', 'w')
	csv.write("Title;Front;Back\n")
	problems.each do |problem|
		solution = Solution.new()
		solution.from_s(File.read(solutionFilepath(problem)))
		front  = solution.question.gsub('"', '""').lines[2..-1].join
		answer = solution.answer  .gsub('"', '""').lines
		if answer.length() >= 2 then 
			answer = answer[2..-1].join
		else
			next
		end
		title = sprintf("%04d %s", problem.index, problem.title)
		csv.write("#{title};\"#{front}\";\"#{answer}\"\n")
	end
	csv.close()
end

def blogToAnswers() 
	FileUtils.mkdir_p('./answers')
	Dir['/Users/jash/dev/blog/content/post/leetcode/*.md'].each do |filepath|
		next if filepath.include?("leetcode-solutions.md")
		lines = File.read(filepath).lines
		l = 0
		l += 1 while l < lines.length and !lines[l].include?('##')
		h = l
		while true do
			h += 1 while h < lines.length and !lines[h].include?('##')
			lines[l] =~ /^## (\d+)\. (.+)$/
			index = $1.to_i
			title = $2.strip
			data  = lines[l+1..h-1].join()
			fname = sprintf('%04d.md', index)
			f = File.open("./answers/#{fname}", 'w')
			f.write(data)
			f.close()
			break if h >= lines.length
			l, h = h, h+1
		end
	end
end

def fillAnswers() 
	Dir['./problems/*.md'].each do |filepath|
		puts filepath
		solution = Solution.new()
		solution.from_s(File.read(filepath))
		answerPath = sprintf('./answers/%04d.md', solution.problem.index)
		if not File.exists?(answerPath) then
			puts solution.problem.index
			next
		end
		answer = File.read(answerPath)
		next if solution.answer == 'todo'
		solution.answer = answer
		File.write(filepath, solution.to_s)
	end
end

def listTodo()
	Dir['./problems/*.md'].each do |filepath|
		solution = Solution.new()
		solution.from_s(File.read(filepath))
		answerPath = sprintf('./answers/%04d.md', solution.problem.index)
		if not File.exists?(answerPath) then
			puts solution.problem.index
			next
		end
	end
end

def removeDuplicateMark()
	Dir['./problems/*.md'].each do |filepath|
		first = true
		result = []
		File.read(filepath).lines.each do |line|
			if line.include?('<!--front-->') then
				if first then 
					first = false
				else
					next
				end
			end
			result << line
		end
		File.write(filepath, result.join())
	end
end

exportToCSV()