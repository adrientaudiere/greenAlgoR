# Frequently Asked Questions and Troubleshooting

## General Questions

### What is greenAlgoR?

`greenAlgoR` is an R package that estimates the carbon footprint and energy consumption of computational tasks. It's based on the Green Algorithms framework by Lannelongue et al. (2021) and helps researchers understand the environmental impact of their computational work in R.

### How accurate are the estimates?

The estimates are based on the peer-reviewed Green Algorithms methodology and use real-world data for:
- CPU power consumption from hardware specifications
- Regional carbon intensity from energy grid data
- Memory power consumption from published research

However, actual consumption may vary based on specific hardware configurations, software optimization, and other factors.

### Which locations are supported?

The package supports carbon intensity data for many countries and regions. Common location codes include:
- `"WORLD"` - Global average
- `"US"` - United States
- `"GB"` - United Kingdom
- `"DE"` - Germany
- `"CN"` - China
- `"FR"` - France 

See the Green Algorithms database for the complete list.

## Common Issues

### "CPU model not found" error

**Problem**: You get an error when specifying a `cpu_model`.

**Solution**: 
1. Use `"Any"` to use generic TDP values instead of a specific model
2. Check that your CPU model name exactly matches the Green Algorithms database
3. Manually specify `TDP_per_core` and `n_cores` instead of using `cpu_model`


### Memory detection issues

**Problem**: Memory RAM is not detected automatically.

**Solution**: Manually specify the `memory_ram` parameter:

```r
ga_footprint(runtime_h = 1, memory_ram = 16)  # 16 GB
```

### Session runtime calculation

**Problem**: `runtime_h = "session"` gives unexpected results.

**Explanation**: Session runtime is calculated from when R started, not when your analysis began. For specific computations, use explicit runtime:

```r
# Time a specific operation
start_time <- Sys.time()
# ... your computation ...
end_time <- Sys.time()
runtime_hours <- as.numeric(difftime(end_time, start_time, units = "hours"))

ga_footprint(runtime_h = runtime_hours)
```

### Targets pipeline issues

**Problem**: `ga_targets()` fails or gives zero footprint.

**Solutions**:
1. Ensure you're in a directory with a targets project
2. Check that targets have been run with `tar_make()`
3. Verify targets metadata exists:

```r
# Check if targets data exists
targets::tar_meta()

# If no data, run the pipeline first
targets::tar_make()
```

## Best Practices

### Choosing appropriate parameters

**Hardware Configuration**:
- Use actual hardware specs when possible
- For cloud computing, check provider documentation
- Personal laptops typically have PUE close to 1.0 
- Data centers typically have PUE = 1.2-2.0

**Location Selection**:
- Use your actual geographical location
- For cloud computing, use the data center location
- Consider running computations in regions with cleaner energy (lower carbon intensity)

### Optimizing for lower carbon footprint

1. **Reduce runtime**: Optimize your code for efficiency
2. **Choose efficient hardware**: Match resources to your needs
3. **Select clean energy regions**: Run computations where renewable energy is prevalent
4. **Cache results**: Avoid re-running expensive computations
5. **Profile your code**: Identify and optimize bottlenecks

### Integration with workflows

**For research projects**:

```r
# Include in your analysis scripts
footprint <- ga_footprint(runtime_h = "session")
cat("Analysis carbon footprint:", footprint$carbon_footprint_total_gCO2, "g CO2\n")

# Save for reporting
saveRDS(footprint, "results/carbon_footprint.rds")
```

**For targets pipelines**:
```r
# Add to your _targets.R file
list(
  # ... your other targets ...
  tar_target(
    carbon_footprint,
    ga_targets(location_code = "FR"),
    description = "Calculate pipeline carbon footprint"
  )
)
```

## Technical Details

### Understanding the output

The `ga_footprint()` function returns a list with detailed breakdown:

- `carbon_footprint_total_gCO2`: Total CO2 emissions in grams
- `carbon_footprint_cores`: CPU contribution to emissions
- `carbon_footprint_memory`: Memory contribution to emissions  
- `energy_needed_kWh`: Total energy consumption in kilowatt-hours
- `runtime_h`: Actual runtime used in calculation
- `ref_value`: Reference activities for comparison (if requested)

### Customizing calculations

**Custom carbon intensity**:
Currently, the package uses predefined carbon intensity values per country. If you are interested in custom values, please post an issue.

**Custom hardware parameters**:
You can specify hardware configurations:

```r
ga_footprint(
  runtime_h = 2,
  TDP_per_core = 25,    # High-performance CPU
  n_cores = 16,         # Many cores
  memory_ram = 128,     # Large memory
  PUE = 1.4,           # Data center efficiency
  PSF = 3              # Account for 3 repeated runs
)
```

## Getting Help

1. **Check the documentation**: Use `?ga_footprint` and `?ga_targets`
2. **Read the vignettes**: `vignette("greenAlgoR-intro")` and `vignette("targets-integration")`
3. **Report issues**: Submit bug reports at https://github.com/adrientaudiere/greenAlgoR/issues

## Contributing

We welcome contributions! See the repository README for guidelines on:
- Reporting bugs
- Suggesting features  
- Submitting code improvements
- Improving documentation

## References

- Lannelongue, L., Grealey, J., Inouye, M. (2021). Green Algorithms: Quantifying the Carbon Footprint of Computation. Advanced Science, 8(12), 2100707.
- Green Algorithms website: https://calculator.green-algorithms.org/
- Package repository: https://github.com/adrientaudiere/greenAlgoR