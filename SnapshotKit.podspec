Pod::Spec.new do |spec|
  spec.name = 'SnapshotKit'
  spec.version = '1.0.0'
  spec.summary = 'Tests that save and assert against reference data'
  spec.license = 'MIT'
  spec.homepage = 'https://github.com/lunij/SnapshotKit'

  spec.source = {
    git: 'https://github.com/lunij/SnapshotKit.git',
    tag: s.version
  }

  spec.swift_versions = '5.4'

  spec.ios.deployment_target = '11.0'
  spec.osx.deployment_target = '10.13'
  spec.tvos.deployment_target = '11.0'

  spec.frameworks = 'XCTest'
  spec.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO' }

  spec.source_files  = 'Sources', 'Sources/**/*.swift'
end
