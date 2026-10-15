// Decompile static combos of a csgo_customweapon .vcs to GLSL, plus a JSON
// sidecar per combo with what the reference runner (src/valveReference.ts)
// needs to bind it: the sRGB-read flag of each texture VARIANT the combo uses,
// and the shader-side default + CPU Expression of every other variable.
//
//   dotnet run -c Release -- <csgo_customweapon_vulkan_50_ps.vcs> <outDir> [id,id,...]
//
// Writes c<id:D5>.glsl + c<id:D5>.json (the names src/valveCombos/ expects) and
// program.json (feature table + every variable). See README.md.
using System.Text.Json;
using ValveResourceFormat.CompiledShader;
using ValveResourceFormat.Serialization.VfxEval;
using Vortice.SpirvCross;

var inPath = args[0];
var outDir = args[1];
var only = args.Length > 2 ? args[2].Split(',').Select(long.Parse).ToHashSet() : null;
Directory.CreateDirectory(outDir);

// Read from a copy: the VRF CLI is known to overwrite a .vcs in place, and the
// library is not worth trusting more than that with the only copy.
// A unique directory each run: the copy keeps the source's permissions, so a
// read-only master would make a fixed temp path un-overwritable next time.
// VfxProgramData derives the program type from the FILE NAME, so it must stay.
var workDir = Directory.CreateTempSubdirectory("valve-combos-");
var work = Path.Combine(workDir.FullName, Path.GetFileName(inPath));
File.Copy(inPath, work);

using var prog = new VfxProgramData();
prog.Read(work);
Console.WriteLine($"{Path.GetFileName(inPath)} vcs={prog.VcsVersion} type={prog.VcsProgramType} combos={prog.StaticComboEntries.Count}");

var features = prog.StaticComboArray.Select(c => new { c.Name, c.RangeMin, c.RangeMax, Mult = c.ComboIndexValue }).ToArray();
foreach (var f in features) Console.WriteLine($"  {f.Name} {f.RangeMin}-{f.RangeMax} x{f.Mult}");

string Eval(byte[] b)
{
    if (b.Length == 0) return "";
    try { return new VfxEval(b, omitReturnStatement: true).DynamicExpressionResult; }
    catch (Exception e) { return "ERR " + e.Message; }
}

// The whole feature table + variable list, for a full dump into a scratch dir.
// Skipped when picking ids, which is how combos land in src/valveCombos.
if (only == null) File.WriteAllText(Path.Combine(outDir, "program.json"), JsonSerializer.Serialize(new
{
    file = Path.GetFileName(inPath),
    vcs = prog.VcsVersion,
    features,
    combos = prog.StaticComboEntries.Keys.ToArray(),
    vars = prog.VariableDescriptions.Select(v => new
    {
        v.Index, v.Name, Source = v.VariableSource.ToString(), Type = v.VfxType.ToString(),
        v.FloatDefs, v.IntDefs, v.SrgbRead, Expr = Eval(v.CompiledExpression),
    }),
}, new JsonSerializerOptions { WriteIndented = true }));

var n = 0;
foreach (var id in prog.StaticComboEntries.Keys)
{
    if (only != null && !only.Contains(id)) continue;
    var combo = prog.GetStaticCombo(id);
    var state = features
        .Select(f => (f.Name, V: (int)((id / Math.Max(1, f.Mult)) % (f.RangeMax - f.RangeMin + 1)) + f.RangeMin))
        .Where(t => t.V != 0).Select(t => $"{t.Name}={t.V}").ToArray();
    var used = combo.AllVariables.Fields
        .Select(f => f.VariableIndex)
        .Where(i => i < prog.VariableDescriptions.Length)
        .Select(i => prog.VariableDescriptions[i])
        .ToArray();
    // Texture sRGB-ness differs per combo for the SAME name (g_tPattern is
    // linear for mask styles, sRGB for artwork styles).
    var srgb = used.Where(v => v.Name.StartsWith("g_t", StringComparison.Ordinal))
        .GroupBy(v => v.Name).ToDictionary(g => g.Key, g => g.First().SrgbRead);
    var vars = used.Where(v => !v.Name.StartsWith("g_t", StringComparison.Ordinal))
        .GroupBy(v => v.Name)
        .ToDictionary(g => g.Key, g => new { f = g.First().FloatDefs, i = g.First().IntDefs, type = g.First().VfxType.ToString(), expr = Eval(g.First().CompiledExpression) });
    File.WriteAllText(Path.Combine(outDir, $"c{id:D5}.json"), JsonSerializer.Serialize(new { id, state, srgb, vars }));

    // The composite has a single dynamic combo; take shader file 0.
    if (combo.ShaderFiles.Length == 0 || combo.ShaderFiles[0] is not VfxShaderFileVulkan vk || vk.IsEmpty()) continue;
    var ok = ShaderSpirvReflection.ReflectSpirv(vk, Backend.GLSL, out var code);
    File.WriteAllText(Path.Combine(outDir, $"c{id:D5}.glsl"),
        $"// static {id}: {string.Join(" ", state)}\n" + (ok ? "" : "// REFLECTION FAILED\n") + code);
    n++;
}
Console.WriteLine($"wrote {n} combos");
