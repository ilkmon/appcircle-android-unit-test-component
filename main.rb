require 'yaml'
require 'open3'
require 'find'
require 'fileutils'
require 'pathname'

def get_env_variable(key)
	return (ENV[key] == nil || ENV[key] == "") ? nil : ENV[key]
end

ac_variants = get_env_variable("AC_VARIANTS") || abort('Missing variants.')
ac_repo_path = get_env_variable("AC_REPOSITORY_DIR") || abort('Missing AC_REPOSITORY_DIR variable.')
temp_folder = get_env_variable("AC_TEMP_DIR") || abort('Missing AC_TEMP_DIR variable.')
ac_project_path = get_env_variable("AC_PROJECT_PATH") || "."
ac_module = get_env_variable("AC_MODULE") || abort('Missing module.')
ac_output_folder = get_env_variable("AC_OUTPUT_DIR") || abort('Missing output folder.')

$exit_status_code = 0
def run_command(command, skip_abort)
    puts "@[command] #{command}"
    status = nil
    stdout_str = nil
    stderr_str = nil

    Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
        stdout.each_line do |line|
            puts line
        end
        stdout_str = stdout.read
        stderr_str = stderr.read
        status = wait_thr.value
    end

    unless status.success?
        puts stderr_str
        unless skip_abort
            exit -1
        end
        $exit_status_code = -1
    end
end

gradlew_folder_path = ""
if Pathname.new("#{ac_project_path}").absolute?
    gradlew_folder_path = ac_project_path
else
    gradlew_folder_path = File.expand_path(File.join(ac_repo_path, ac_project_path))
end

gradle_task = ""
ac_variants.split(',').each { 
    | variant | gradle_task << " :#{ac_module}:test#{variant.capitalize}UnitTest"
}

run_command("cd #{gradlew_folder_path} && chmod +x ./gradlew && ./gradlew#{gradle_task}", true)

build_folder_path = "#{gradlew_folder_path}/#{ac_module}/build"

puts "Copying test results to the output directory"
puts "#{build_folder_path}/test-results => $AC_OUTPUT_DIR/test-results"
run_command("cp -R #{build_folder_path}/test-results #{ac_output_folder}/test-results", false)

puts "Copying reports to the output directory"
puts "#{build_folder_path}/reports/tests => $AC_OUTPUT_DIR/tests"
run_command("cp -R #{build_folder_path}/reports/tests #{ac_output_folder}/tests", false)

exit $exit_status_code