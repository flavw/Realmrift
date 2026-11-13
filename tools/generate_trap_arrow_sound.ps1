# Original crossbow release and arrow flight, synthesized as 44.1 kHz mono PCM.
$sampleRate = 44100
$duration = 0.48
$count = [int]($sampleRate * $duration)
$samples = [double[]]::new($count)
$random = [Random]::new(90731)
$filteredNoise = 0.0
$previousNoise = 0.0
$peak = 0.0
for ($i = 0; $i -lt $count; $i++) {
    $t = $i / [double]$sampleRate
    $noise = $random.NextDouble() * 2.0 - 1.0
    $filteredNoise = 0.72 * $filteredNoise + 0.28 * $noise
    $latch = (0.22 * [Math]::Sin(2 * [Math]::PI * 1760 * $t) + 0.30 * ($noise - $previousNoise)) * [Math]::Exp(-$t * 125)
    $string = (0.25 * [Math]::Sin(2 * [Math]::PI * 192 * $t) + 0.12 * [Math]::Sin(2 * [Math]::PI * 583 * $t)) * [Math]::Exp(-$t * 38)
    $flightEnvelope = [Math]::Min(1.0, $t / 0.035) * [Math]::Exp(-$t * 9.5)
    $flight = ($filteredNoise * 0.62 + 0.035 * [Math]::Sin(2 * [Math]::PI * (2200 * $t - 1400 * $t * $t))) * $flightEnvelope
    $fade = [Math]::Min(1.0, $t / 0.0015) * [Math]::Min(1.0, ($duration - $t) / 0.06)
    $samples[$i] = ($latch + $string + $flight) * $fade
    $peak = [Math]::Max($peak, [Math]::Abs($samples[$i]))
    $previousNoise = $noise
}
$assetPath = Join-Path (Split-Path -Parent $PSScriptRoot) 'assets/audio/trap_arrow.wav'
$stream = [IO.File]::Create($assetPath)
$writer = [IO.BinaryWriter]::new($stream)
try {
    $writer.Write([Text.Encoding]::ASCII.GetBytes('RIFF'))
    $writer.Write([int](36 + $count * 2))
    $writer.Write([Text.Encoding]::ASCII.GetBytes('WAVEfmt '))
    $writer.Write([int]16); $writer.Write([int16]1); $writer.Write([int16]1)
    $writer.Write([int]$sampleRate); $writer.Write([int]($sampleRate * 2))
    $writer.Write([int16]2); $writer.Write([int16]16)
    $writer.Write([Text.Encoding]::ASCII.GetBytes('data')); $writer.Write([int]($count * 2))
    foreach ($sample in $samples) { $writer.Write([int16][Math]::Round($sample / $peak * 27000)) }
} finally {
    $writer.Dispose()
}
Write-Output "Created trap_arrow.wav: $duration seconds, $sampleRate Hz, mono PCM16."
