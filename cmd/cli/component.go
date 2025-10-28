package cli

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"

	"github.com/complytime/gemara2oscal/component"
	oscalTypes "github.com/defenseunicorns/go-oscal/src/types/oscal-1-1-3"
	"github.com/goccy/go-yaml"
	"github.com/ossf/gemara/layer2"
	"github.com/ossf/gemara/layer4"
	"github.com/spf13/cobra"
)

func NewComponentCommand() *cobra.Command {
	var catalogPath, targetComponent, componentType, evaluationsPath, parametersPath string

	command := &cobra.Command{
		Use:   "component",
		Short: "Transform Gemara artifacts to OSCAL Component Definitions",
		RunE: func(cmd *cobra.Command, args []string) error {
			builder := component.NewDefinitionBuilder("Example", "0.1.0")

			cleanedPath := filepath.Clean(catalogPath)
			catalogData, err := os.ReadFile(cleanedPath)
			if err != nil {
				return err
			}

			var layer2Catalog layer2.Catalog
			err = yaml.Unmarshal(catalogData, &layer2Catalog)
			if err != nil {
				return err
			}

			parameters := make(component.Parameters)
			if err := parameters.Load(parametersPath); err != nil {
				return err
			}

			builder = builder.AddTargetComponent(targetComponent, componentType, layer2Catalog, parameters)

			err = filepath.Walk(evaluationsPath, func(path string, info os.FileInfo, err error) error {

				if info.IsDir() {
					return nil
				}

				content, err := os.ReadFile(path)
				if err != nil {
					return err
				}

				var plan layer4.EvaluationPlan
				err = yaml.Unmarshal(content, &plan)
				if err != nil {
					return err
				}

				builder = builder.AddValidationComponent(plan)
				return nil
			})

			compDef := builder.Build()

			oscalModels := oscalTypes.OscalModels{
				ComponentDefinition: &compDef,
			}
			compDefData, err := json.MarshalIndent(oscalModels, "", " ")
			if err != nil {
				return err
			}
			_, _ = fmt.Fprintln(os.Stdout, string(compDefData))
			return nil
		},
	}

	flags := command.Flags()
	flags.StringVarP(&catalogPath, "catalog-path", "c", "./governance/catalogs/osps.yml", "Path to L2 catalog to transform")
	flags.StringVarP(&evaluationsPath, "evaluations-path", "e", "./governance/plans", "Path to Layer 4 evaluation plans")
	flags.StringVarP(&targetComponent, "target-component", "t", "", "Title for target component for evaluation")
	flags.StringVar(&componentType, "component-type", "software", "Component type (based on valid OSCAL component types)")
	flags.StringVarP(&parametersPath, "parameters-path", "p", "./governance/parameters.yaml", "Path to policy parameters")
	return command
}
