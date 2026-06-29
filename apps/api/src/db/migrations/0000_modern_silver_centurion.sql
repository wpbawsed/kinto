CREATE TYPE "public"."report_type" AS ENUM('wrong_location', 'closed', 'wrong_info');--> statement-breakpoint
CREATE TYPE "public"."resource_type" AS ENUM('aed', 'ltc_abc', 'accessible_toilet');--> statement-breakpoint
CREATE TABLE "reports" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"resource_id" uuid,
	"report_type" "report_type" NOT NULL,
	"user_lat" numeric(10, 7),
	"user_lng" numeric(10, 7),
	"note" text,
	"created_at" timestamp with time zone DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "resources" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"type" "resource_type" NOT NULL,
	"name" text NOT NULL,
	"address" text,
	"phone" text,
	"lat" numeric(10, 7),
	"lng" numeric(10, 7),
	"open_hours" jsonb,
	"source_id" text,
	"verified" boolean DEFAULT false NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now()
);
--> statement-breakpoint
ALTER TABLE "reports" ADD CONSTRAINT "reports_resource_id_resources_id_fk" FOREIGN KEY ("resource_id") REFERENCES "public"."resources"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE UNIQUE INDEX "resources_type_source_id_uq" ON "resources" USING btree ("type","source_id");